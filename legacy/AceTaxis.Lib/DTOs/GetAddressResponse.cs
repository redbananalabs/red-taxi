using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AceTaxis.DTOs
{
    public class GetAddressResponseDto
    {
        public List<Suggestion> suggestions { get; set; }
    }

    public class Suggestion
    {
        public string address { get; set; }
        public string url { get; set; }
        public string id { get; set; }
    }
}
