using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc;


[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
public class AuthorizeAttribute : Attribute, IAuthorizationFilter
{
    public void OnAuthorization(AuthorizationFilterContext context)
    {
        var user = context.HttpContext.Items["User"];
        if (user == null)
        {
            var lockout = false;
            try
            {
                lockout = (bool)context.HttpContext.Items["LockedOut"];
            }
            catch (NullReferenceException)
            {
                // expected on first run
            }

            if (lockout)
            {
                // user not logged in
                context.Result = new JsonResult(new
                {
                    message = "User Locked"
                })
                {
                    StatusCode = StatusCodes.Status423Locked
                };
            }
            else
            {
                // user not logged in
                context.Result = new JsonResult(new
                {
                    message = "Unauthorized"
                })
                {
                    StatusCode = StatusCodes.Status401Unauthorized
                };
            }
        }
    }
}
