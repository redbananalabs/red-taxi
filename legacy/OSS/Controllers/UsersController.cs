using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using OSS.Membership;


[Route("api/[controller]")]
[ApiController]
[ApiExplorerSettings(GroupName = "core")]
public class UsersController : ControllerBase
{
    private readonly IUsersService _usersService;
    private readonly IAuthenticationService _authenticationService;
    private readonly ILogger<UsersController> _logger;

    public UsersController(IUsersService usersService,
        IAuthenticationService authenticationService,
        ILogger<UsersController> logger)
    {
        _usersService = usersService;
        _authenticationService = authenticationService;
        _logger = logger;
    }

    [AllowAnonymous]
    [HttpGet("Test")]
    public async Task<IActionResult> Test()
    {
        return Ok("Yes Working");
    }

    [AllowAnonymous]
    [HttpPost]
    [Route("Register")]
    public async virtual Task<IActionResult> Register([FromBody] RegisterUserRequestDto model)
    {
        if(ModelState.IsValid) 
        {
            var existingUser = await _usersService.FindByName(model.Username);

            if (existingUser != null)
            {
                _logger.LogInformation($"username already in use - {model.Username} - retry");
                return BadRequest("Username already in use");
            }

            var newUser = new AppUser()
            {
                Email = model.Email,
                UserName = model.Username,
                PhoneNumber = model.PhoneNumber, 
                FullName = model.Fullname
            };

            var isCreated = await _usersService.Create(newUser, model.Password);

            if (isCreated.Succeeded)
            {
                // add user to role
                var registerWithRole = string.Empty;

                switch (model.RoleName)
                {
                    case "Admin":
                        registerWithRole = "Admin";
                        break;
                    case "User":
                        registerWithRole = "User";
                        break;
                    default:
                        if (string.IsNullOrEmpty(model.RoleName))
                            registerWithRole = "User";
                        else
                            registerWithRole = model.RoleName;
                        break;
                }

                var role = await _usersService.GetRoleFromRoleName(registerWithRole);

                if (role != null)
                {
                    await _usersService.AddUserToRole(newUser, role.Name);
                }
                else // default
                {
                    await _usersService.AddUserToRole(newUser, "User");
                }

                var auth = await _authenticationService.GetAPIToken(new AuthenticateRequest {
                    UserName = model.Username,
                    Password = model.Password,
                });

                _logger.LogInformation($"user created - {model.Username}");

                return Ok(auth);
            }
            else
            {
                return BadRequest(isCreated.Errors.Select(x => x.Description).FirstOrDefault());
            }
        }

        return BadRequest("Invalid payload");
    }

    [Authorize]
    [HttpGet]
    [Route("AddUserToRole")]
    public async Task<IActionResult> AddUserToRole(int userId, string roleName)
    {
        var user = await _usersService.FindById(userId);
        return Ok(await _usersService.AddUserToRole(user, roleName));
    }

    [Authorize]
    [HttpGet]
    [Route("CheckPassword")]
    public async Task<IActionResult> CheckPassword(int userId, string password)
    {
        var user = await _usersService.FindById(userId);
        return Ok(await _usersService.CheckPassword(user, password));
    }

    [Authorize]
    [HttpGet]
    [Route("FindByUserId")]
    public async Task<AppUser> FindByUserId(int id)
    {
        return await _usersService.FindById(id);
    }

    [Authorize]
    [HttpGet]
    [Route("FindByUsername")]
    public async Task<AppUser?> FindByUsername(string username)
    {
        return await _usersService.FindByName(username);
    }

    [Authorize]
    [HttpGet]
    [Route("FindByUsernamePassword")]
    public async Task<AppUser?> FindByUsernamePassword(string username, string password)
    {
        return await _usersService.FindByUsernamePassword(username, password);
    }

    [Authorize]
    [HttpGet]
    [Route("GetRoleFromRoleName")]
    public async Task<AppRole?> GetRoleFromRoleName(string name)
    {
        return await _usersService.GetRoleFromRoleName(name);
    }

    [Authorize]
    [HttpGet]
    [Route("GetUsersRoles")]
    public async Task<IList<string>> GetUsersRoles(int userId)
    {
        var user = await _usersService.FindById(userId);
        return await _usersService.GetUserRoles(user);
    }

    [Authorize]
    [HttpGet]
    [Route("GetAllUsers")]
    public IActionResult GetAllUsers()
    {
        var users = _usersService.GetAll();
        return Ok(users);
    }

    [Authorize]
    [HttpGet]
    [Route("IsLockedOut")]
    public async Task<bool> IsLockedOut(int userId)
    {
        return await _usersService.IsLockedOut(userId);
    }

    [Authorize]
    [HttpGet]
    [Route("LockoutOnOff")]
    public async Task LockoutOnOff(int userId, bool lockout)
    {
        var user = await _usersService.FindById(userId);
        await _usersService.LockoutOnOff(user, lockout);
    }
}

