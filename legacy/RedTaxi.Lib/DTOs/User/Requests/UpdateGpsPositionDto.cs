using System.ComponentModel.DataAnnotations;

namespace RedTaxi.DTOs.User.Requests
{
    public class UpdateGpsPositionDto
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public decimal Longtitude { get; set; }

        [Required]
        public decimal Latitude { get; set; }

        public decimal Speed { get; set; }

        [Required]
        public decimal Heading { get; set; }
    }

    public class TestGPS
    {
        [Required]
        public string Username { get; set; }

        [Required]
        public decimal Longtitude { get; set; }

        [Required]
        public decimal Latitude { get; set; }

        public decimal Speed { get; set; }

        [Required]
        public decimal Heading { get; set; }
    }
}
