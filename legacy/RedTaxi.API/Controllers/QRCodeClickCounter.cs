using RedTaxi.Services;
using Microsoft.AspNetCore.Mvc;

namespace RedTaxi.API.Controllers
{
    [Route("qrcode/{location}")]
    [ApiController]
    public class QRCodeClickCounter : ControllerBase
    {
        private readonly UrlTrackingService _service;

        public QRCodeClickCounter(UrlTrackingService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<IActionResult> RedirectToLongUrl([FromRoute] string location)
        {
            await _service.RecordQRCodeClick(location);
            return Redirect($"https://acetaxisdorset.co.uk?referer={location}");
        }

    }
}
