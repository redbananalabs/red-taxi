using AceTaxis.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using Microsoft.Extensions.Logging;

namespace AceTaxis.Services
{
    public abstract class BaseService<T>
    {
        internal readonly AceDbContext _dB;
        public readonly ILogger<T> _logger;

        public BaseService(
            AceDbContext dB, ILogger<T> logger)
        {
            _logger = logger;
            _dB = dB;
        }

        public BaseService(
            IDbContextFactory<AceDbContext> factory, ILogger<T> logger)
        {
            _dB = factory.CreateDbContext();
            _logger = logger;
        }

        public IDbContextTransaction Transaction()
        {
            return _dB.Database.BeginTransaction();
        }
    }
}
