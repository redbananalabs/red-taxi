using RedTaxi.Domain;
using System.ComponentModel.DataAnnotations;

namespace RedTaxi.DTOs.LocalPOI
{
    public class GetLocalPOIRequest
    {
        public string? SearchTerm { get; set; }
    }

    public class CreatePOIRequest : ModelValidator
    {
        public string? Name { get; set; }
        [Required]
        public string Address { get; set; }
        [Required]
        public string Postcode { get; set; }
        [Required]
        public LocalPOIType Type { get; set; }
    }

    public class UpdatePOIRequest : CreatePOIRequest
    {
        [Required]
        public int Id { get; set; }
    }

    public class DeletePOIRequest
    {
        [Required]
        public int Id { get; set; }
    }
}
