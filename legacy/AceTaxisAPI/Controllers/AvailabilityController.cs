using AceTaxis.Data;
using AceTaxis.Services;
using Microsoft.AspNetCore.Mvc;

namespace AceTaxisAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AvailabilityController : ControllerBase
    {
        private readonly AceDbContext _db;
        private readonly AvailabilityService _service;
        private readonly AceMessagingService _messagingService;

        public AvailabilityController(AvailabilityService service, AceMessagingService messaging, AceDbContext db)
        {
            _db = db;
            _service = service;
            _messagingService = messaging;
        }

        [HttpGet]
        [Authorize]
        [Route("General")]
        public async Task<IActionResult> GetGeneralAvailability(DateTime date)
        {
            var data = await _service.GetGeneralAvailability(date);
            return Ok(data);

        }

        [HttpGet]
        //[Authorize]
        [Route("Reminder")]
        public async Task<IActionResult> SendReminder(string key)
        {
            if (key == "ace@taxis")
            {
                await _messagingService.SendDriverAvailabilityReminderSMS();
                return Ok();
            }

            return BadRequest("invalid key");
        }
    }
}
