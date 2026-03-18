using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using RedTaxi.Modules.Membership;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

public interface IAuthenticationService
{
    Task<AuthenticateResponse> GetAPIToken(AuthenticateRequest model);
    Task<string> GenerateJwtToken(AppUser user);
    AppRefreshToken GenerateRefreshToken(int userId);
    Task<AuthenticateResponse> ValidateRefreshToken(RefreshTokenRequest model);
}

public class AuthenticationService : IAuthenticationService
{
    private readonly JwtConfig _jwtConfig;
    private readonly AppDbContext _db;
    private readonly ILogger<AuthenticationService> _logger;
    private readonly UsersService _usersService;
    private readonly TokenValidationParameters _tokenvps;

    public AuthenticationService(IOptions<JwtConfig> jwtConfig,
        AppDbContext dbContext,
        ILogger<AuthenticationService> logger,
        IUsersService usersService,
        TokenValidationParameters tokenValidationParameters)
    {
        _jwtConfig = jwtConfig.Value;
        _db = dbContext;
        _logger = logger;
        _usersService = (UsersService)usersService;
        _tokenvps = tokenValidationParameters;
    }

    public async Task<AuthenticateResponse> GetAPIToken(AuthenticateRequest model)
    {
        var user = await _usersService.FindByUsernamePassword(model.UserName, model.Password);

        // return null if user not found
        if (user == null) return null;

        // authentication successful so generate jwt token
        var expiry = DateTime.Now.AddDays(_jwtConfig.ExpiryDays);
        var token = await GenerateJwtToken(user);

        // check we have a refresh token in db
        var existing = await _db.AppRefreshTokens.Where(o=>o.UserId == user.Id).FirstOrDefaultAsync();

        var refreshToken = string.Empty;

        if (existing == null) // none - create one
        {
            // generate refresh token
            var refresh = GenerateRefreshToken(user.Id);

            // persist refresh token
            await _db.AppRefreshTokens.AddAsync(refresh);
            await _db.SaveChangesAsync();

            refreshToken = refresh.Token;
        }
        else
        {
            refreshToken = existing.Token;
        }

        // Returns User details and Jwt token in HttpResponse which will be user to authenticate the user.
        return new AuthenticateResponse(user, token, expiry, refreshToken, true, null);
    }

    public async Task<AuthenticateResponse> ValidateRefreshToken(RefreshTokenRequest model)
    {
        var jwtTokenHandler = new JwtSecurityTokenHandler();

        try
        {
            // validation 1 - validate JWT token format
            var tokenInVerification = jwtTokenHandler.ValidateToken(model.Token, _tokenvps, out var validatedToken);

            // validation 2 - validate encyption algorithm
            if (validatedToken is JwtSecurityToken jwtSecurityToken)
            {
                var result = jwtSecurityToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha256, StringComparison.InvariantCultureIgnoreCase);

                if (result == false)
                    return null;
            }

            // validation 3 - validate expiry date
            var utcExpiryDate = long.Parse(tokenInVerification.Claims.FirstOrDefault(x => x.Type == JwtRegisteredClaimNames.Exp).Value);

            var expiryDate = UnixTimestampToDateTime(utcExpiryDate);

            if (expiryDate > DateTime.UtcNow)
            {
                return new AuthenticateResponse(false, "Token has not expired");
            }

            // validation 4 - validate existence of token
            var storedToken = await _db.AppRefreshTokens.FirstOrDefaultAsync(x => x.Token == model.RefreshToken);

            if (storedToken == null)
            {
                return new AuthenticateResponse(false, "Token does not exist");
            }

            // validation 5 - validate if used
            if (storedToken.IsUsed)
            {
                return new AuthenticateResponse(false, "Token has been used");
            }

            // validation 6 - validate if revoked
            if (storedToken.IsRevoked)
            {
                return new AuthenticateResponse(false, "Token has been revoked");
            }

            // validation 7 - validate id
            var jti = tokenInVerification.Claims.FirstOrDefault(x => x.Type == JwtRegisteredClaimNames.Jti).Value;

            if (storedToken.JwtId != jti)
            {
                return new AuthenticateResponse(false, "Token does not match");
            }

            // update current token
            storedToken.IsUsed = true;
            _db.AppRefreshTokens.Update(storedToken);

            // generate new token
            var dbuser = await _usersService.FindById(storedToken.UserId);
            var expiry = DateTime.Now.AddDays(_jwtConfig.ExpiryDays);
            var token = await GenerateJwtToken(dbuser);

            // generate new refresh token
            var refresh = GenerateRefreshToken(dbuser.Id);

            // add new refresh token
            await _db.AppRefreshTokens.AddAsync(refresh);

            // save all chanages
            await _db.SaveChangesAsync();

            return new AuthenticateResponse
            {
                RefreshToken = refresh.Token,
                Token = token,
                TokenExpiry = expiry,
                Username = dbuser.UserName,
                Success = true,
            };
        }
        catch (SecurityTokenExpiredException ex)
        {
            _logger.LogError($"security error generating refresh token - expired refresh token", ex);
            return new AuthenticateResponse(false, ex.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError($"unhandled error generating refresh token", ex);
            return new AuthenticateResponse(false, ex.Message);
        }
    }

    public async Task<string> GenerateJwtToken(AppUser user)
    {
        var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtConfig.Key));
        var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);
        var expiry = DateTime.Now.AddDays(_jwtConfig.ExpiryDays);

        var roles = await _usersService.GetUserRoles(user);
        var role = roles.FirstOrDefault();

        if (role == null)
        {
            role = "User";
        }

        // Here you  can fill claim information from database for the users as well
        var claims = new[] {
                new Claim("id", user.Id.ToString()),
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Name, user.UserName),
                new Claim(JwtRegisteredClaimNames.Sub, user.UserName),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim("Role", role),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

        var token = new JwtSecurityToken(_jwtConfig.Issuer, _jwtConfig.Issuer,
            claims,
            expires: expiry,
            signingCredentials: credentials);
        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public AppRefreshToken GenerateRefreshToken(int userId)
    {
        var refreshToken = new AppRefreshToken()
        {
            JwtId = userId.ToString(),
            IsUsed = false,
            IsRevoked = false,
            UserId = Convert.ToInt32(userId),
            CreatedOn = DateTime.UtcNow,
            ExpiryDate = DateTime.Now.AddDays(_jwtConfig.RefreshExpiryDays),
            Token = RandomString(35) + Guid.NewGuid()
        };

        return refreshToken;
    }

    #region PRIVATE

    private DateTime UnixTimestampToDateTime(long unixTimestamp)
    {
        var datetimeVal = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
        datetimeVal = datetimeVal.AddSeconds(unixTimestamp).ToLocalTime();
        return datetimeVal;
    }

    private string RandomString(int length)
    {
        var random = new Random();
        var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

        return new string(Enumerable.Repeat(chars, length)
            .Select(x => x[random.Next(x.Length)]).ToArray());
    }
    #endregion
}
