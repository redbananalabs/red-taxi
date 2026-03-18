using AceTaxis.Data;
using AceTaxis.Data.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace AceTaxis.Services
{
    public class UrlTrackingService : BaseService<UrlTrackingService>
    {
        public UrlTrackingService(AceDbContext dB, ILogger<UrlTrackingService> logger)
            : base(dB, logger) { }

        public async Task<string?> ResolveAndTrackShortUrl(string shortCode)
        {
            var mapping = await _dB.UrlMappings.FirstOrDefaultAsync(m => m.ShortCode == shortCode);
            if (mapping == null) return null;

            mapping.Clicks++;
            _dB.UrlMappings.Update(mapping);
            await _dB.SaveChangesAsync();

            return mapping.LongUrl;
        }

        public async Task RecordQRCodeClick(string location)
        {
            var click = new QRCodeClick();
            click.Location = location;
            click.TimeStamp = DateTime.Now.ToUKTime();

            await _dB.QRCodeClicks.AddAsync(click);
            await _dB.SaveChangesAsync();
        }
    }
}
