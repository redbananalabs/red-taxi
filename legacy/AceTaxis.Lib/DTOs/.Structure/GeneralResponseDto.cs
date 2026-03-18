using Newtonsoft.Json;

namespace AceTaxis.DTOs
{
    public class GeneralResponseDto
    {

        public GeneralResponseDto()
        {

        }

        [JsonProperty("Success")]
        public bool Success { get; set; }
        [JsonProperty("Error")]
        public string Error { get; set; }

        public object Value { get; set; }
    }
}
