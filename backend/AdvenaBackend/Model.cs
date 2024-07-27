using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AdvenaBackend
{
    class RecommendationPayloadData
    {
       public String userId {  get; set; }
       public String userLocation { get; set; }
       public List<String> interests { get; set; }
       public SocialPreferences socialPreferences {  get; set; }
    }

    class SocialPreferences
    {
        public String dining { get; set; }
        public int groupSize { get; set; }
        public String socializing { get; set;}
    }
}
