using RedTaxi.Services;
using Microsoft.AspNetCore.Mvc;

namespace RedTaxi.API.Controllers
{
    [Route("/u/{shortCode}")]
    [ApiController]
    public class RedirectController : ControllerBase
    {
        private readonly UrlTrackingService _service;
        public RedirectController(UrlTrackingService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<IActionResult> RedirectToLongUrl([FromRoute] string shortCode)
        {
            var longUrl = await _service.ResolveAndTrackShortUrl(shortCode);
            if (longUrl == null)
                return NotFound();

            return Redirect(longUrl);
        }
    }
}
