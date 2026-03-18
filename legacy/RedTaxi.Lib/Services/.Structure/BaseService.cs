using RedTaxi.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using Microsoft.Extensions.Logging;

namespace RedTaxi.Services
{
    public abstract class BaseService<T>
    {
        internal readonly RedTaxiDbContext _dB;
        public readonly ILogger<T> _logger;

        public BaseService(
            RedTaxiDbContext dB, ILogger<T> logger)
        {
            _logger = logger;
            _dB = dB;
        }

        public BaseService(
            IDbContextFactory<RedTaxiDbContext> factory, ILogger<T> logger)
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
