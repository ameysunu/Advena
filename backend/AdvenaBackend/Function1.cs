using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

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
            dynamic data = JsonConvert.DeserializeObject(requestBody);

            if(data == null)
            {
                return new BadRequestObjectResult(new { error = "Payload cannot be null" });
            }

            var userId = data.userId;
            return new OkObjectResult($"Welcome to Azure Functions {userId}");
        }
    }
}
