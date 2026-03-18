using AceTaxis.Data;
using AceTaxis.Data.Models;
using AceTaxis.Domain;
using AceTaxis.DTOs;
using AceTaxis.DTOs.User.Requests;
using AceTaxis.DTOs.User.Responses;
using AceTaxis.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using OSS.Membership;
using System.Data;

namespace AceTaxis.Areas.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [ApiExplorerSettings(GroupName = "v1")]
    public class UserProfileController : ControllerBase
    {
        private readonly AceDbContext _appDbContext;
        private readonly UserProfileService _profileService;
        private readonly IUsersService _usersService;
        private readonly IAuthenticationService _authService;
        private readonly ILogger<UserProfileController> _logger;
        private readonly IMemoryCache _memoryCache;

        public UserProfileController(
            UserProfileService profileService,
            AceDbContext appDbContext,
            IUsersService usersService,
            IAuthenticationService authenticationService,
            ILogger<UserProfileController> logger,
            IMemoryCache memoryCache)
        {
            _appDbContext = appDbContext;
            _logger = logger;
            _profileService = profileService;
            _usersService = usersService;
            _authService = authenticationService;
            _memoryCache = memoryCache;
        }


        [HttpPost]
        [Route("Register")]
        [ProducesResponseType(typeof(RegistrationLoginResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<RegistrationLoginResponseDto>> Register([FromBody] UserRegistrationRequestDto model)
        {
            if (ModelState.IsValid) 
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

                var profile = new UserProfile();
                profile.ColorCodeRGB = model.ColorCode;
                profile.RegNo = model.RegistrationNo;
                profile.UserId = newUser.Id;

                var response = new RegistrationLoginResponseDto();

                if (isCreated.Succeeded)
                {
                    _appDbContext.UserProfiles.Update(profile);
                    await _appDbContext.SaveChangesAsync();

                    // add user to role
                    var registerWithRole = model.Role == AceRoles.Admin ? "Admin" : "Driver";
                    var role = await _profileService.GetRoleFromRoleName(registerWithRole);

                    if (role != null)
                    {
                        await _profileService.AddUserToRole(newUser, role.Name);
                    }
                    else
                    {
                        await _profileService.AddUserToRole(newUser, "Driver");
                    }

                    _logger.LogInformation($"user created - {model.Username}");

                    var roles = await _profileService.GetUserRoles(newUser);

                    var roleId = await _profileService.GetRoleId(role);

                    response.RoleId = Convert.ToInt32(roleId);
                    response.IsAdmin = role.Name == "Admin" ? true : false;

                    var auth = await _authService.GetAPIToken(new AuthenticateRequest
                    {
                        UserName = model.Username,
                        Password = model.Password,
                    });

                    response.Success = true;
                    response.RefreshToken = auth.RefreshToken;
                    response.Token = auth.Token;
                    response.RegNo = model.RegistrationNo;
                    response.FullName = model.Fullname;

                    return Ok(response);
                }
                else
                {
                    return BadRequest(isCreated.Errors.Select(x => x.Description).FirstOrDefault());
                }
            }

            return BadRequest("invalid payload");
        }

        [HttpPost]
        [Route("Login")]
        [ProducesResponseType(typeof(RegistrationLoginResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<RegistrationLoginResponseDto>> Login([FromBody] UserLoginRequestDto model)
        {
            var response = new RegistrationLoginResponseDto();

            var auth = await _authService.GetAPIToken(new AuthenticateRequest { 
                UserName = model.Username, 
                Password = model.Password
            });

            if (auth == null)
                return BadRequest(new { message = "Username/password is incorrect or username not found." });
            else
            {
                // get user & profile
                var profile = await _profileService.GetProfile(model.Username);

                if (profile != null)
                {
                    if (profile.User.LockoutEnabled)
                    {
                        return new StatusCodeResult(StatusCodes.Status423Locked);
                    }

                    var roles = await _profileService.GetUserRoles(profile.User);
                    var role = roles.FirstOrDefault();
                    var roleObj = await _profileService.GetRoleFromRoleName(role);
                    var roleId = await _profileService.GetRoleId(roleObj);

                    response.RoleId = Convert.ToInt32(roleId);
                    response.IsAdmin = role == "Admin" ? true : false;
                    response.UserId = profile.UserId;
                    response.Success = true;
                    response.RefreshToken = auth.RefreshToken;
                    response.Token = auth.Token;
                    response.TokenExpiry = auth.TokenExpiry;
                    response.RegNo = profile.RegNo;
                    response.FullName = profile.User.FullName;

                    // update last login date
                    await _profileService.UpdateLastLoginDateTime(profile.UserId);

                    return Ok(response);
                }
            }

            return BadRequest(new RegistrationLoginResponseDto()
            {
                Error = "Invalid payload",
                Success = false
            });
        }

        [HttpPost]
        [Route("RefreshToken")]
        [ProducesResponseType(typeof(RegistrationLoginResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<RegistrationLoginResponseDto>> RefreshToken([FromBody] RefreshTokenRequestDto model)
        {
            if (ModelState.IsValid)
            {
                _logger.LogInformation($"validating refresh token {model.RefreshToken}");

                var result = await _authService.ValidateRefreshToken(new RefreshTokenRequest 
                { 
                    Token = model.Token, 
                    RefreshToken = model.RefreshToken
                });

                if (result == null)
                {
                    return BadRequest("Invalid token");
                }
                else
                {
                    _logger.LogInformation($"refresh token validation success: {result.Success}");

                    if (result.Success)
                    {
                        _logger.LogInformation($"returning token {result.RefreshToken}");
                        return Ok(result);
                    }
                    else
                    {
                        _logger.LogInformation($"validation reason error: {result.Errors.FirstOrDefault()}");
                        return BadRequest(result.Errors.FirstOrDefault());
                    }
                }
            }

            return BadRequest("invalid payload");
        }

        [HttpPost]
        [Route("Update")]
        [ProducesResponseType(typeof(bool), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [Authorize]
        public async Task<IActionResult> Update(UserUpdateDetailsRequestDto request)
        {
            if(!string.IsNullOrEmpty(request.FullName))
            {
                var uname = User.Identity.Name;

                if(!string.IsNullOrEmpty(uname))
                {
                    var user = await _profileService.FindByName(uname);

                    if (user != null)
                    {
                        await _profileService.UpdateUser(user, request.FullName, request.RegNo);
                        return Ok(new GeneralResponseDto { Success = true });
                    }
                }
                return BadRequest("user not found from token");
            }
            else
            {
                return BadRequest("Fullname is required.");
            }
        }

        [HttpPost]
        [Route("UpdateFCM")]
        [ProducesResponseType(typeof(bool), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [Authorize]
        public async Task<IActionResult> UpdateFCM(UpdateFCMRequestDto request)
        {
            if (!string.IsNullOrEmpty(request.fcm))
            {
                var uname = User.Identity.Name;

                if (!string.IsNullOrEmpty(uname))
                {
                    var user = await _profileService.FindByName(uname);

                    if (user != null)
                    {
                        await _profileService.UpdateFCMToken(user, request.fcm);
                        return Ok(new GeneralResponseDto { Success = true });
                    }
                }
                return BadRequest("user not found from token");
            }
            else
            {
                return BadRequest("FCM Token is required.");
            }
        }

        [HttpGet]
        [Route("ListUsers")]
        [ProducesResponseType(typeof(UsersListResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [Authorize]
        public async Task<IActionResult> ListUsers()
        {
            UsersListResponseDto dto = null;

            if(!_memoryCache.TryGetValue("users",out dto))
            {
                dto = await _profileService.ListUsers();
                
                _memoryCache.Set("users", dto, 
                    new MemoryCacheEntryOptions()
                    .SetAbsoluteExpiration(TimeSpan.FromMinutes(30)));
            }
            
            return Ok(dto);
        }

        [HttpGet]
        [Route("GetUser")]
        [Authorize]
        public async Task<AppUser?> GetUser(string username) 
        {
            return await _profileService.FindByName(username);
        }

        [HttpPost]
        [Route("UpdateGPS")]
        [Authorize]
        public async Task<IActionResult> UpdateUserGPS(UpdateGpsPositionDto request) 
        {
            var user = await _profileService.FindById(request.UserId);
            if (user != null)
            {
                await _profileService.UpdateGpsPosition(user, request.Longtitude, request.Latitude, request.Speed, request.Heading);
                return Ok();
            }
            else
                return BadRequest("User not found.");
        }

        [HttpGet]
        [Route("GetGPS")]
        [Authorize]
        public async Task<ActionResult<UserGPSResponseDto>> GetUserGPS(int userId) 
        {
            var res = await _profileService.GetGpsPosition(userId);
            return Ok(res);
        }

        [HttpGet]
        [Route("GetAllGPS")]
        //[Authorize]
        public async Task<ActionResult<List<UserGPSResponseDto>>> GetAllUsersGPS()
        {
            var res = await _profileService.GetAllCurrentGpsPositionsCache();
            return Ok(res);
        }


        [HttpPost]
        [Route("SetAvailability")]
        [Authorize]
        public async Task<IActionResult> SetAvailability(DateTime date, string description)
        {
            var uname = User.Identity.Name;

            if (!string.IsNullOrEmpty(uname))
            {
                var user = await _profileService.FindByName(uname);

                if (user != null)
                {
                    await _profileService.CreateUpdateAvailability(user, date, description);

                    return Ok(new GeneralResponseDto { Success = true });
                }
            }
            return Ok();
        }

        [HttpPost]
        [Route("GetAvailability")]
        [Authorize]
        public async Task<IActionResult> GetAvailability(RequestAvailabilityDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var data = await _profileService.GetAvailabilities(dto.Date);
            return Ok(data);
        }

        [HttpGet]
        [Route("ResetPassword")]
        public async Task<IActionResult> ResetPassword(int userId)
        {
            var email = await _profileService.GetEmail(userId);
            var password = await _profileService.ChangePassword(email);

            return Ok(password);
        }


        [HttpPost]
        [Route("Upload")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> Post(IFormFile file)
        {
            // full path to file in temp location
            var filePath = Path.GetTempFileName();

            if (file.Length > 0)
            {
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }
            }

            // process uploaded files
            // Don't rely on or trust the FileName property without validation.

            var count = await _profileService.ImportCsv(filePath);

            return Ok(count);
        }

        public class FileUpload
        {
            public IFormFile File { get; set; }
        }
    }
}
