namespace AceTaxis.DTOs.User.Responses
{
    public class RegistrationLoginResponseDto : GeneralResponseDto
    {
        public string FullName { get; set; }
        public string RegNo { get; set; }
        public int UserId { get; set; }

        public string Token { get; set; }
        public DateTime TokenExpiry { get; set; }
        public string RefreshToken { get; set; }

        public bool IsAdmin { get; set; }
        public int RoleId { get; set; }

        public string Type { get; set; }

        public enum FailType
        { 
            User,
            Token
        }
    }
}
