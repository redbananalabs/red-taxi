using Microsoft.AspNetCore.Mvc;
using RabbitMQ.Client.Events;
using RabbitMQ.Client;
using System.Text;
using Newtonsoft.Json;
using RedTaxi.DTOs.Booking;
using RedTaxi.Data;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Services;
using RedTaxi.DTOs.MessageTemplates;
using Microsoft.AspNetCore.Identity;

namespace RedTaxi.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SmsQueController : ControllerBase
    {
        private readonly RedTaxiDbContext _db;
        private ConnectionFactory _factory;
        private IConnection _connection;
        private IModel _channel;
        private EventingBasicConsumer _consumer;
        private string _queName;
        private string _consumerTag;
        private readonly AceMessagingService _messaging;
        private readonly UserActionsService _actions;
        private readonly UserManager<AppUser> _userManager;

        public SmsQueController(RedTaxiDbContext dB, 
            AceMessagingService messaging, 
            BookingService booking, UserActionsService actions, 
            UserManager<AppUser> userManager)
        {
            _db = dB;
            _messaging = messaging;
            _actions = actions;
            _userManager = userManager;
        }

        [HttpGet]
        [Route("Get")]
        public async Task<ActionResult> GetMessages() 
        {
            try
            {
                var time = DateTime.Now.ToUKTime();
                await _db.MessagingNotifyConfig.ExecuteUpdateAsync(o => o.SetProperty(u => u.SmsPhoneHeartBeat, time));
            }
            catch(Exception ex)
            { 

            }

            var username = "acetaxis";
            var password = "ace";
            var host = "85.234.135.182";
            var port = 5672;
            var queName = "messages";
            var routingKey = "ace-routing-key";

            _factory = new ConnectionFactory();
            _factory.Uri = new Uri($"amqp://{username}:{password}@{host}:{port}");
            _factory.ClientProvidedName = "AceTaxis";

            _connection = _factory.CreateConnection();
            _channel = _connection.CreateModel();

            _channel.ExchangeDeclare("AceExchange", ExchangeType.Direct);
            _channel.QueueDeclare(queName, false, false, false);
            _channel.QueueBind(queName, "AceExchange", routingKey, null);
            _channel.BasicQos(0, 1, false);

            // _consumer = new EventingBasicConsumer(_channel);
            // _consumer.Received += _consumer_Received;
            // _consumer.Shutdown += _consumer_Shutdown;

            // this consumer tag identifies the subscription
            // when it has to be cancelled
            // _consumerTag = _channel.BasicConsume(queName, false, _consumer);
            var e = _channel.BasicGet(queName, true);
            
            _channel.Close();
            _connection.Close();

            if (e != null)
            {
                var str = e.Body.ToArray();
                var message = Encoding.UTF8.GetString(str);

                try
                {
                    var obj = JsonConvert.DeserializeObject<RabbitMessagePacket>(message);

                    if (obj != null)
                    {
                        return Ok(obj);
                    }
                }
                catch(Exception ex)
                {
                    return BadRequest(ex);
                }
            }

            return NotFound();
        }

        [Authorize]
        [HttpPost]
        [Route("SendText")]
        public async Task SendTextMessage(string message, string telephone)
        { 
            await _messaging.SendSmsAsync(message, telephone);

            var uname = User.Identity.Name;
            var fname = string.Empty;

            if (!string.IsNullOrEmpty(uname))
            {
                var user = await _userManager.FindByNameAsync(uname);

                if (user != null)
                {
                    fname = user.FullName;
                }
            }

            await _actions.LogSendText(telephone, fname);

        }

      
    }
}
