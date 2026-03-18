using AceTaxis.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AceTaxisAPI.Controllers
{
    [Route("/u/{shortCode}")]
    [ApiController]
    public class RedirectController : ControllerBase
    {
        private readonly AceDbContext _db;
        public RedirectController(AceDbContext db)
        {
            _db = db;
        }

        [HttpGet]
        public async Task<IActionResult> RedirectToLongUrl([FromRoute] string shortCode)
        {
            var mapping = await _db.UrlMappings.FirstOrDefaultAsync(m => m.ShortCode == shortCode);
            if (mapping == null)
                return NotFound();

            mapping.Clicks++;
            _db.UrlMappings.Update(mapping);
            await _db.SaveChangesAsync();

            return Redirect(mapping.LongUrl);
        }
    }
}
