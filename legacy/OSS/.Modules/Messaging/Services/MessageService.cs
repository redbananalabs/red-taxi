using Microsoft.AspNetCore.Identity.UI.Services;
using Microsoft.Extensions.Options;
using SendGrid.Helpers.Mail;
using SendGrid;
using System.Collections.Specialized;
using System.Net;
using System.Text;
using Twilio;
using Twilio.Rest.Api.V2010.Account;
using Twilio.Types;
using Newtonsoft.Json;
using OSS.Messaging.Services;
using Microsoft.Extensions.Logging;

namespace OSS.Messaging
{
    public interface IMessageService
    {
        Task SendEmailAsync(string email, string subject, string htmlMessage);
        Task SendEmailAsync(string email, string subject, string htmlMessage, string[] attachments = null);
        Task<bool> SendSmsAsync(string number, string message);
        Task SendTransactionalEmail(string toEmail, string toName, string subject, string templateId, object data, string bcc);
    }

    public class MessageService : PushNotificationService, IEmailSender, IMessageService
    {
        private readonly MessagingConfig _config;
        private readonly ISendGridClient _sendGrid;

        public MessageService(IOptions<MessagingConfig> config, ISendGridClient sendGrid) : base(config)
        {
            _config = config.Value;
            _sendGrid = sendGrid;
        }

        public async Task<bool> SendSmsAsync(string message,string number)
        {
            var res = false;

            var resp = await Task.Run(() =>
            {
                using (var wb = new WebClient())
                {
                    byte[] response = wb.UploadValues("https://api.txtlocal.com/send/", new NameValueCollection()
                        {
                        {"apikey" , _config.Sms.ApiKey},
                        {"numbers" , number},
                        {"message" , message},
                        {"sender" , _config.Sms.Sender},
                        { "test", _config.Sms.Testing}
                        });
                    var result = Encoding.UTF8.GetString(response);
                    return result;
                }
            });

            return res;
        }

        public async Task SendEmailAsync(string email, string subject, string htmlMessage, string[] attachments = null)
        {
            var msg = new SendGridMessage()
            {
                From = new EmailAddress(_config.Email.Sender, _config.Email.SenderName),
                Subject = subject,
                //PlainTextContent = message,
                HtmlContent = htmlMessage, 
                Attachments = new List<Attachment>()
            };

            foreach (var attachment in attachments)
            {
               // msg.AddAttachment(attachment, Convert.ToBase64String(attachment.Content), attachment.MimeType);
               throw new NotImplementedException();
            }

            msg.SetClickTracking(false,false);
            msg.SetOpenTracking(false);
            msg.AddTo(new EmailAddress(email));

            await _sendGrid.SendEmailAsync(msg);
        }

        public async Task SendEmailAsync(string email, string subject, string htmlMessage)
        {
            var msg = new SendGridMessage()
            {
                From = new EmailAddress(_config.Email.Sender, _config.Email.SenderName),
                Subject = subject,
                //PlainTextContent = message,
                HtmlContent = htmlMessage
            };
            msg.SetClickTracking(false, false);
            msg.SetOpenTracking(false);
            msg.AddTo(new EmailAddress(email));

            await _sendGrid.SendEmailAsync(msg);
        }

        public async Task SendTransactionalEmail(string toEmail, string toName, string subject, string templateId, object data, string bcc = "")
        {
            var msg = new SendGridMessage();
            msg.Subject = subject;
            msg.SetSubject(subject);
            msg.SetTemplateId(templateId);
            msg.SetFrom(_config.Email.Sender, _config.Email.SenderName);
            msg.AddTo(toEmail, toName);
            msg.SetTemplateData(data);

            msg.SetClickTracking(false, false);
            msg.SetOpenTracking(false);

            if (!string.IsNullOrEmpty(bcc))
            {
                msg.AddBcc(bcc);
            }

            var res = await _sendGrid.SendEmailAsync(msg);

            if (res.StatusCode != HttpStatusCode.Accepted)
            { 
                var str = await res.Body.ReadAsStringAsync();
            }
        }

        public async Task<bool> SendTransactionalEmail(string toEmail, string toName, string subject, string templateId, object data, string filename, string base64Content, string bcc = "")
        {
            var msg = new SendGridMessage();
            msg.Subject = subject;
            msg.SetSubject(subject);
            msg.SetTemplateId(templateId);
            msg.SetFrom(_config.Email.Sender, _config.Email.SenderName);
            msg.AddTo(toEmail, toName);
            
            if(data != null)
                msg.SetTemplateData(data);

            msg.AddAttachment(filename,base64Content);
            msg.SetClickTracking(false, false);
            msg.SetOpenTracking(false);

            if (!string.IsNullOrEmpty(bcc))
            {
                msg.AddBcc(bcc);
            }

            var res = await _sendGrid.SendEmailAsync(msg);

            if (res.StatusCode == HttpStatusCode.Accepted)
            {
                return true;
            }

            return false;
        }

        public async Task<bool> SendTransactionalEmail(string toEmail, string toName, string subject, string templateId, object data, Dictionary<string,string> attachments, string bcc = "")
        {
            var msg = new SendGridMessage();
            msg.Subject = subject;
            msg.SetSubject(subject);
            msg.SetTemplateId(templateId);
            msg.SetFrom(_config.Email.Sender, _config.Email.SenderName);
            msg.AddTo(toEmail, toName);

            if (data != null)
                msg.SetTemplateData(data);

            foreach (var attachment in attachments) 
            {
                msg.AddAttachment(attachment.Key, attachment.Value);
            }
            
            msg.SetClickTracking(false, false);
            msg.SetOpenTracking(false);

            if (!string.IsNullOrEmpty(bcc))
            {
                msg.AddBcc(bcc);
            }

            var res = await _sendGrid.SendEmailAsync(msg);

            if (res.StatusCode == HttpStatusCode.Accepted)
            {
                return true;
            }

            return false;
        }

        /// <summary>
        /// Send WhatsApp via the Twilio API Service
        /// </summary>
        public async virtual Task SendWhatsAppMessage(string toNumber, string message)
        {
            if(toNumber.StartsWith("0"))
                toNumber = "44" + toNumber.Substring(1);

            if(!toNumber.StartsWith("+"))
                toNumber = "+" + toNumber;

            try
            {
                // Find your Account Sid and Token at twilio.com/console
                // and set the confif. See http://twil.io/secure
                var accountSid = _config.Twilio.TWILIO_ACCOUNT_SID;
                var authToken = _config.Twilio.TWILIO_AUTH_TOKEN;

                TwilioClient.Init(accountSid,authToken);
                //

                var messageRessource = await MessageResource.CreateAsync(
                    body: message,
                    from: new PhoneNumber("whatsapp:+441747822228"),//(_config.Twilio.TWILIO_FROM_CHANNEL),
                    to: new PhoneNumber($"whatsapp:{toNumber}")
                );
            }
            catch (Exception ex)
            {
                
            }
        }

        public async virtual Task<MessageResource?> SendWhatsApp(string toNumber, Dictionary<string,Object> variables, string templateId)
        {
            if (toNumber.StartsWith("0"))
                toNumber = "44" + toNumber.Substring(1);

            if (!toNumber.StartsWith("+"))
                toNumber = "+" + toNumber;


            if (toNumber.Contains("7825350912") || toNumber.Contains("7738825598"))
                return null;

            var contentVariables = JsonConvert.SerializeObject(variables, Formatting.Indented);

            try
            {
                // Find your Account Sid and Token at twilio.com/console
                // and set the confif. See http://twil.io/secure
                var accountSid = _config.Twilio.TWILIO_ACCOUNT_SID;
                var authToken = _config.Twilio.TWILIO_AUTH_TOKEN;

                TwilioClient.Init(accountSid, authToken);

                
                var message = await MessageResource.CreateAsync(
                    contentSid: templateId,
                    //from: new PhoneNumber("MGb33701de6a1ab01db5fb77e5db3b4def"),
                    messagingServiceSid: "MGb33701de6a1ab01db5fb77e5db3b4def",
                    contentVariables: contentVariables,
                    to: new PhoneNumber($"whatsapp:{toNumber}"));

                return message;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }
    }
}
