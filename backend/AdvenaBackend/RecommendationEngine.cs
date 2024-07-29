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


            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            RecommendationPayloadData data = JsonConvert.DeserializeObject<RecommendationPayloadData>(requestBody);

            if (data == null)
            {
                return new BadRequestObjectResult(new { error = "Payload cannot be null" });
            }
            bool isInterests = data.isInterests;

            String jsonPayload = QueryPreparerForGemini(log, data, isInterests);
            String geminiResults = await GetDataFromGemini(log, jsonPayload);

            if (geminiResults.Contains("Error"))
            {
                return new BadRequestObjectResult(new { error = geminiResults });
            }

            return new OkObjectResult(geminiResults);
        }

        public static String QueryPreparerForGemini(ILogger logger, RecommendationPayloadData data, bool isInterests)
        {
            String userTextContent = "";
            String country = data.userLocation;

            if (isInterests)
            {

                logger.LogInformation("Query type is of interests");

                String interests = String.Join(",", data.interests);
                userTextContent = $"Suggest me top 10 places in {country} for my interests: {interests}";
            } else
            {
                logger.LogInformation("Query type is of social preferences");

                String dining = data.socialPreferences.dining;
                String groupSize = data.socialPreferences.groupSize.ToString();
                String socializing = data.socialPreferences.socializing;

                userTextContent = $"Suggest me top 10 places in {country} that incorporate my social preferences as - dining: {dining}, my group size: {groupSize} and my socializing type of being {socializing}";
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
        
        public static async Task<String> GetDataFromGemini(ILogger log, String payload)
        {
            log.LogInformation("Preparing to send data to Gemini");

            var configuration = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("local.settings.json", optional: true, reloadOnChange: true)
                .AddEnvironmentVariables()
                .Build();

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

    }
}
