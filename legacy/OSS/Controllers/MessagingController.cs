using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using OSS.Messaging;
using OSS.Messaging.Services;


[ApiController]
[Route("api/[controller]")]
[ApiExplorerSettings(GroupName = "core")]
public class MessagingController : ControllerBase
{
    private readonly IMessageService _messagService;
    private readonly IPushNotificationService _pushNotificationService;

    public MessagingController(IMessageService messageService,
        IPushNotificationService pushNotificationService,
        ILogger<MessagingController> logger)
    {
        _messagService = messageService;
        _pushNotificationService = pushNotificationService;
    }

    [Authorize]
    [HttpPost]
    [Route("SendTextMessage")]
    public async Task<IActionResult> SendTextMessage(SendTextMessageRequestDto request)
    {
        if (ModelState.IsValid)
        {
            await _messagService.SendSmsAsync(request.Telephone, request.Message);
            return Ok();
        }

        return BadRequest(ModelState);
    }

    [Authorize]
    [HttpPost]
    [Route("SendPushNotification")]
    public async Task<IActionResult> SendPushNotification(PushNotificationRequest request)
    {
        if (ModelState.IsValid)
        {
            await _pushNotificationService.SendAndroidNotification(request);
            return Ok();
        }

        return BadRequest(ModelState);
    }
}
