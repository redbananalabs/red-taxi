namespace AceTaxis.DTOs.User
{
    public class AuthResult
    {
        public string Token { get; set; }
        public DateTime TokenExpiry { get; set; }
        public string RefreshToken { get; set; }
        public bool Success { get; set; }
        public string[] Errors { get; set; }
    }
}
