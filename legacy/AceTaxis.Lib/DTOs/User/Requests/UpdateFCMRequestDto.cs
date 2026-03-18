using System.ComponentModel.DataAnnotations;

namespace AceTaxis.DTOs.User.Requests
{
    public class UpdateFCMRequestDto
    {
        [Required]
        public string fcm { get; set; }
    }
}
