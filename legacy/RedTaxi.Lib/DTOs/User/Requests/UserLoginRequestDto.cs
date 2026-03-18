using System.ComponentModel.DataAnnotations;

namespace RedTaxi.DTOs.User.Requests
{
    public class UserLoginRequestDto
    {
        [Required(), MinLength(3), MaxLength(30)]
        public string Username { get; set; }

        [Required(), MinLength(3), MaxLength(30)]
        public string Password { get; set; }
    }

    public class UserUpdateDetailsRequestDto
    {
        [Required(), MinLength(2), MaxLength(30)]
        public string FullName { get; set; }

        public string RegNo { get; set; }
    }
}
