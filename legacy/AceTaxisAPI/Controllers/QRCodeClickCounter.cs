using AceTaxis.Data;
using AceTaxis.Data.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AceTaxisAPI.Controllers
{
    [Route("qrcode/{location}")]
    [ApiController]
    public class QRCodeClickCounter : ControllerBase
    {
        private readonly AceDbContext _db;

        public QRCodeClickCounter(AceDbContext db)
        {
            _db = db;
        }

        [HttpGet]
        public async Task<IActionResult> RedirectToLongUrl([FromRoute] string location)
        {
            var click = new QRCodeClick();
            click.Location = location;
            click.TimeStamp = DateTime.Now.ToUKTime();

            await _db.QRCodeClicks.AddAsync(click);
            await _db.SaveChangesAsync();

            return Redirect($"https://acetaxisdorset.co.uk?referer={location}");
        }

    }
}
