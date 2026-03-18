using System.ComponentModel.DataAnnotations;

namespace RedTaxi.DTOs.User.Requests
{
    public class UpdateFCMRequestDto
    {
        [Required]
        public string fcm { get; set; }
    }
}
