using Newtonsoft.Json;

namespace RedTaxi.Shared
{
    public class ResponseDTO
    {
        public ResponseDTO()
        {
            Errors = new List<string>();
        }

        [JsonProperty("Success")]
        public bool Success { get; set; }

        [JsonProperty("Errors")]
        public List<string> Errors { get; set; }

        public object Result { get; set; }
    }
}
