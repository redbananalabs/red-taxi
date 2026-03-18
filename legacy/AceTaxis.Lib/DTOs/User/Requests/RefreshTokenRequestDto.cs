using System.ComponentModel.DataAnnotations;


namespace AceTaxis.DTOs.User.Requests
{
    public class RefreshTokenRequestDto
    {
        [Required]
        public string Token { get; set; }

        [Required]
        public string RefreshToken { get; set; }
    }
}
