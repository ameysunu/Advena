using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AdvenaBackend
{
    public class RecommendationPayloadData
    {
       public String userId {  get; set; }
       public String userLocation { get; set; }
       public bool isInterests { get; set; }
       public List<String> interests { get; set; }
       public SocialPreferences socialPreferences {  get; set; }
    }

    public class SocialPreferences
    {
        public String dining { get; set; }
        public int groupSize { get; set; }
        public String socializing { get; set;}
    }

    public class Response
    {
        public List<Candidate> candidates { get; set; }
    }

    public class Content
    {
        public List<Part> parts { get; set; }
        public string role { get; set; }
    }

    public class Candidate
    {
        public Content content { get; set; }
        public string finishReason { get; set; }
        public int index { get; set; }
        public List<SafetyRating> safetyRatings { get; set; }
    }

    public class Part
    {
        public string text { get; set; }
    }

    public class SafetyRating
    {
        public string category { get; set; }
        public string probability { get; set; }
    }

    public class Places
    {
       public List<Place> places { get; set; }
    }

    public class Place
    {
       public string id { get; set; }
       public string formattedAddress { get; set; }
    }

    public class GeminiInterestsResponse
    {
        public string title { get; set; }
        public string description { get; set; }
        public string location { get; set; }
        public string address { get; set; }
    }
}
