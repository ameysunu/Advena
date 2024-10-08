using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Extensions.Configuration;
using System.Net.Http;
using System.Text;
using Google.Cloud.Firestore;
using Google.Apis.Auth.OAuth2;
using System.Collections.Generic;
using Google.Cloud.Firestore.V1;
using Grpc.Auth;

namespace AdvenaBackend
{
    public static class RecommendationEngine
    {
        [FunctionName("RecommendationEngine")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            var configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("local.settings.json", optional: true, reloadOnChange: true)
    .AddEnvironmentVariables()
    .Build();

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            RecommendationPayloadData data = JsonConvert.DeserializeObject<RecommendationPayloadData>(requestBody);

            if (data == null)
            {
                return new BadRequestObjectResult(new { error = "Payload cannot be null" });
            }
            bool isInterests = data.isInterests;

            String jsonPayload = QueryPreparerForGemini(log, data, isInterests);
            String geminiResults = await GetDataFromGemini(log, jsonPayload, configuration);

            if (geminiResults.Contains("Error"))
            {
                return new BadRequestObjectResult(new { error = geminiResults });
            }

            var isWriteSuccess = await WriteDataToFirestore(log, configuration, data, geminiResults, isInterests);
            
            if (isWriteSuccess)
            {
                return new OkObjectResult("Recommendation Engine successfully processed all data");
            }

            return new OkObjectResult("Done");
            
        }

        public static String QueryPreparerForGemini(ILogger logger, RecommendationPayloadData data, bool isInterests)
        {
            String userTextContent = "";
            String country = data.userLocation;
            String interestsQueryPostFix = "Return the data as a Json with the details: title, description, location and address";

            if (isInterests)
            {

                logger.LogInformation("Query type is of interests");

                String interests = String.Join(",", data.interests);
                userTextContent = $"Suggest me top 10 places in {country} for my interests: {interests}. {interestsQueryPostFix}";
            } else
            {
                logger.LogInformation("Query type is of social preferences");

                String dining = data.socialPreferences.dining;
                String groupSize = data.socialPreferences.groupSize.ToString();
                String socializing = data.socialPreferences.socializing;

                userTextContent = $"Suggest me top 10 places in {country} that incorporate my social preferences as - dining: {dining}, my group size: {groupSize} and my socializing type of being {socializing}. {interestsQueryPostFix}. The Json data alone would suffice, this data will be serialized.";
            }

            return $@"
        {{
            ""contents"": [
                {{
                    ""parts"": [
                        {{
                            ""text"": ""{userTextContent}""
                        }}
                    ]
                }}
            ]
        }}";
        }
        
        public static async Task<String> GetDataFromGemini(ILogger log, String payload, IConfiguration configuration)
        {
            log.LogInformation("Preparing to send data to Gemini");

            String geminiEndPoint = configuration["GEMINI_ENDPOINT"];
            String geminiApiKey = configuration["GEMINI_API_KEY"];

            String Url = geminiEndPoint + "/gemini-1.5-flash-latest:generateContent?key=" + geminiApiKey;

            using (HttpClient client = new HttpClient())
            {
                HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Post, Url);
                request.Content = new StringContent(payload, Encoding.UTF8, "application/json");

                HttpResponseMessage response = await client.SendAsync(request);
                if (response.IsSuccessStatusCode)
                {
                    string responseBody = await response.Content.ReadAsStringAsync();
                    var responseObj = JsonConvert.DeserializeObject<Response>(responseBody);

                    if (responseObj?.candidates != null && responseObj.candidates.Count > 0)
                    {
                        var text = responseObj.candidates[0].content.parts[0].text;
                        log.LogInformation(text);
                        return text;
                    }

                    return responseBody;
                }
                else
                {
                    string responseBody = await response.Content.ReadAsStringAsync();
                    log.LogInformation($"Failed to call the API. Status code: {response.StatusCode}");
                    return "Error: " + responseBody;
                }
            }
        }

        public static async Task<bool> WriteDataToFirestore(ILogger log, IConfigurationRoot config, RecommendationPayloadData recData, String geminiResult, bool isInterests)
        {
            var fireStoreKeyBase64 = config["FIREBASE_SDK_SERVICE_KEY"];
            var serviceAccountKey = Encoding.UTF8.GetString(Convert.FromBase64String(fireStoreKeyBase64));
            FirestoreDb firestoreDb = await InitializeFirestoreDb(serviceAccountKey);

            Dictionary<string, object> data = new Dictionary<string, object>();
            List<GeminiInterestsResponse> firestoreData = new List<GeminiInterestsResponse>();

            if (geminiResult.StartsWith("```json"))
            {
                var sanitizedGeminiResult = geminiResult.Replace("```json", "").Replace("```", "");

                List<GeminiInterestsResponse> geminiInterestsResponse = JsonConvert.DeserializeObject<List<GeminiInterestsResponse>>(sanitizedGeminiResult);

                foreach (var res in geminiInterestsResponse)
                {
                    Places places = await GetPlacesSearchText(log, config, res.title, recData.userLocation);

                    if (places.places != null)
                    {
                        log.LogInformation("Places response: " + places.places[0].formattedAddress);

                        PlaceDetails placeDetails = await GetPlaceDetails(config, log, places.places[0].id);

                        var regularOpeningHours = placeDetails.regularOpeningHours;
                        bool isPlaceOpen = false;
                        if (regularOpeningHours != null)
                        {
                            isPlaceOpen = regularOpeningHours.openNow;
                        }

                        GeminiInterestsResponse geir = new GeminiInterestsResponse();
                        geir.address = places.places[0].formattedAddress ?? "";
                        geir.id = places.places[0].id ?? "";
                        geir.title = res.title ?? "";
                        geir.location = res.location ?? "";
                        geir.description = res.description ?? "";

                        if(placeDetails.photos != null)
                        {
                            geir.photoUri = ConstructImageUrl(placeDetails.photos[0].name ?? "", config);
                        }

                        geir.rating = placeDetails.rating ?? "";
                        geir.openNow = isPlaceOpen;
                        geir.websiteUri = placeDetails.websiteUri;

                        firestoreData.Add(geir);
                    }
                }

                if (isInterests)
                {
                    data.Add("geminiInterests", firestoreData);
                } else
                {
                    data.Add("geminiSocialPreferences", firestoreData);
                }

                if (firestoreData.Count > 0)
                {
                    return await AddDocumentToFirestore(firestoreDb, "geminidata", recData.userId, data);
                }
            }

            return false;

        }

        private static String ConstructImageUrl(string reference, IConfiguration config)
        {
            string[] parts = reference.Split('/');
            string photoReference = parts[parts.Length - 1];
            string url = $"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference={photoReference}&key={config["GOOGLE_PLACES_API_KEY"]}";

            return url;
        }

        private static async Task<FirestoreDb> InitializeFirestoreDb(string serviceAccountKey)
        {
            GoogleCredential credential;
            using (var stream = new MemoryStream(Encoding.UTF8.GetBytes(serviceAccountKey)))
            {
                credential = GoogleCredential.FromStream(stream);
            }

            FirestoreClientBuilder firestoreClientBuilder = new FirestoreClientBuilder
            {
                ChannelCredentials = credential.ToChannelCredentials()
            };

            FirestoreClient firestoreClient = await firestoreClientBuilder.BuildAsync();
            FirestoreDb firestoreDb = FirestoreDb.Create("ios-project-11c34", firestoreClient);
            return firestoreDb;
        }

        private static async Task<bool> AddDocumentToFirestore(FirestoreDb firestoreDb, string collectionName, string documentId, Dictionary<string, object> data)
        {
            DocumentReference docRef = firestoreDb.Collection(collectionName).Document(documentId);
            await docRef.SetAsync(data, SetOptions.MergeAll);
            return true;
        }

        private static async Task<Places> GetPlacesSearchText(ILogger log, IConfigurationRoot config, String restaurantName, String country)
        {
            String payload = $@"
        {{
            ""textQuery"": "" {restaurantName}, {country}""
        }}";

            String Url = "https://places.googleapis.com/v1/places:searchText";

            using (HttpClient client = new HttpClient())
            {
                HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Post, Url);
                request.Content = new StringContent(payload, Encoding.UTF8, "application/json");
                request.Headers.Add("X-Goog-Api-Key", $"{config["GOOGLE_PLACES_API_KEY"]}");
                request.Headers.Add("X-Goog-FieldMask", "*");
                //request.Headers.Add("X-Goog-FieldMask", "places.formattedAddress");

                HttpResponseMessage response = await client.SendAsync(request);
                if (response.IsSuccessStatusCode)
                {
                    string responseBody = await response.Content.ReadAsStringAsync();
                    var responseObj = JsonConvert.DeserializeObject<Places>(responseBody);

                    return responseObj;
                }
                else
                {
                    string responseBody = await response.Content.ReadAsStringAsync();
                    log.LogInformation($"Failed to call the API. Status code: {response.StatusCode}");
                    return null;
                
                }
            }
        }

        private static async Task<PlaceDetails> GetPlaceDetails(IConfiguration config, ILogger log, String placeId)
        {
            String Url = $"https://places.googleapis.com/v1/places/{placeId}";

            using (HttpClient client = new HttpClient())
            {
                HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Get, Url);
                request.Headers.Add("X-Goog-Api-Key", $"{config["GOOGLE_PLACES_API_KEY"]}");
                request.Headers.Add("X-Goog-FieldMask", "*");
                //request.Headers.Add("X-Goog-FieldMask", "places.formattedAddress");

                HttpResponseMessage response = await client.SendAsync(request);
                if (response.IsSuccessStatusCode)
                {
                    string responseBody = await response.Content.ReadAsStringAsync();
                    var responseObj = JsonConvert.DeserializeObject<PlaceDetails>(responseBody);

                    return responseObj;
                }
                else
                {
                    string responseBody = await response.Content.ReadAsStringAsync();
                    log.LogInformation($"Failed to call the API. Status code: {response.StatusCode}");
                    return null;

                }
            }
        }

    }
}
