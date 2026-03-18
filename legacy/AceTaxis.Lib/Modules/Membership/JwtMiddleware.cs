using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

public class JwtMiddleware
{
    private readonly RequestDelegate _next;
    private readonly JwtConfig _appSettings;
    private readonly TokenValidationParameters _tokenvps;

    public JwtMiddleware(
        RequestDelegate next,
        IOptions<JwtConfig> appSettings,
        TokenValidationParameters tokenValidationParameters)
    {
        _next = next;
        _appSettings = appSettings.Value;
        _tokenvps = tokenValidationParameters;
    }

    public async Task Invoke(HttpContext context, IUsersService userService)
    {
        var token = context.Request.Headers["Authorization"].FirstOrDefault()?.Split(" ").Last();
        if (token != null)
            //Validate the token
            await AttachUserToContext(context, userService, token);
        await _next(context);
    }

    private async Task AttachUserToContext(HttpContext context, IUsersService userService, string token)
    {
        try
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_appSettings.Key));

            tokenHandler.ValidateToken(token, _tokenvps, out SecurityToken validatedToken);

            var jwtToken = (JwtSecurityToken)validatedToken;
            var userId = int.Parse(jwtToken.Claims.First(x => x.Type == "id").Value);

            var user = await userService.FindById(userId);

            if (user != null && !user.LockoutEnabled)
            {
                // attach user to context on successful jwt validation
                context.Items["User"] = user;
                context.Items["LockedOut"] = false;

                var userClaims = new List<Claim>()
                {
                    new Claim("id", user.Id.ToString()),
                    new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                    new Claim(ClaimTypes.Name, user.UserName),
                    new Claim(ClaimTypes.Email, user.Email),
                };

                var userIdentity = new ClaimsIdentity(userClaims, "User Identity");
                var userPrincipal = new ClaimsPrincipal(new[] { userIdentity });

                context.User = userPrincipal;

                await context.SignInAsync(userPrincipal);
            }
            else
            {
                context.Items["LockedOut"] = true;
            }
        }
        catch (Exception)
        {
            // do nothing if jwt validation fails
            // user is not attached to context so request won't have access to secure routes
        }
    }
}
