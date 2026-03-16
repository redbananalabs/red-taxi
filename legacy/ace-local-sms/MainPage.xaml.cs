//using RabbitMQ.Client.Events;
//using RabbitMQ.Client;
using Plugin.Maui.ScreenBrightness;
using System.Net.Http.Json;


namespace SmsSenderApp
{
    public partial class MainPage : ContentPage
    {
        readonly IScreenBrightness _screenBrightness;


        bool started = false;
        int count = 0;
        Timer _timer;
        int ticks = 0;
        //private ConnectionFactory _factory;
        //private IConnection _connection;
        //private IModel _channel;
        //private EventingBasicConsumer _consumer;
        //private string _queName;
        //private string _consumerTag;

        // private SmsService _smsService;


        public MainPage(IScreenBrightness screenBrightness)
        {
            InitializeComponent();
            _screenBrightness = screenBrightness;
            brightnessSlider.Value = _screenBrightness.Brightness;
            // _smsService = new SmsService();
        }


        protected override async void OnAppearing()
        {
            var brightnessService = new BrightnessService();
            var previousBrightness = brightnessService.SetBrightness(1); // Max brightness

            var status = await Permissions.RequestAsync<Permissions.Sms>();
        }

        private async void Begin()
        {
            _timer = new Timer(async _ =>  // async void
            {
                if (ticks == 30)
                {
                    HttpClient client = new HttpClient();
                    client.BaseAddress = new Uri("https://api.acetaxisdorset.co.uk/");

                    try
                    {
                        using (var response = await client.GetAsync("api/SmsQue/Get", HttpCompletionOption.ResponseHeadersRead))
                        {
                            if (response.IsSuccessStatusCode)
                            {
                                var obj = await response.Content.ReadFromJsonAsync<RabbitMessagePacket>();

                                if (obj != null)
                                {
                                    if (!string.IsNullOrEmpty(obj.Telephone) && !string.IsNullOrEmpty(obj.Message))
                                        SendSmsMessage(obj.Telephone, obj.Message);
                                }
                            }
                            else
                            {
                                MainThread.BeginInvokeOnMainThread(() =>
                                {
                                    SentLabel.Text = $"";
                                });
                            }
                        }

                        // we need to Invoke it because we could be on the wrong Thread          
                        MainThread.BeginInvokeOnMainThread(() =>
                        {
                            CounterLabel.Text = $"PROCESSED: {count}";
                        });
                    }
                    catch (Exception ex) 
                    {

                    }

                    ticks = 0;
                }

                MainThread.BeginInvokeOnMainThread(() => 
                {
                    TickLabel.Text = ticks.ToString();
                });
                
                ticks++;

            }, null, 0, 1000);
        }

        private void OnStartStopClicked(object sender, EventArgs e)
        {
            if (started)
            {
                //_channel.BasicCancel(_consumerTag);
                //_channel.Close();
                //_connection.Close();

                CounterBtn.Text = "Stopped";
            }
            else
            {
                StartReciever();
                CounterBtn.Text = "Started";
                started = true;
            }
        }

        void Slider_ValueChanged(System.Object sender, Microsoft.Maui.Controls.ValueChangedEventArgs e)
        {
            _screenBrightness.Brightness = (float)e.NewValue;
            brightnessLabel.Text = $"Current Brightness: {Math.Round(_screenBrightness.Brightness, 2)}";
        }

        private void StartReciever()
        {
            var username = "acetaxis";
            var password = "ace";
            var host = "85.234.135.182";
            var port = 5672;
            var queName = "messages";
            var routingKey = "ace-routing-key";

            //_factory = new ConnectionFactory();
            //_factory.Uri = new Uri($"amqp://{username}:{password}@{host}:{port}");
            //_factory.ClientProvidedName = "AceTaxis";

            //_connection = _factory.CreateConnection();
            //_channel = _connection.CreateModel();

            //_channel.ExchangeDeclare("AceExchange", ExchangeType.Direct);
            //_channel.QueueDeclare(queName, false, false, false);
            //_channel.QueueBind(queName, "AceExchange", routingKey, null);
            //_channel.BasicQos(0, 1, false);

            //_consumer = new EventingBasicConsumer(_channel);
            //_consumer.Received += _consumer_Received;
            //_consumer.Shutdown += _consumer_Shutdown;

            //// this consumer tag identifies the subscription
            //// when it has to be cancelled
            //_consumerTag = _channel.BasicConsume(queName, false, _consumer);

            Begin();
        }

        //private void _consumer_Shutdown(object? sender, ShutdownEventArgs e)
        //{
        //    _consumer.Received -= _consumer_Received;
        //    _consumer.Shutdown -= _consumer_Shutdown;

        //    // re-connect
        //    StartReciever();
        //}

        //private void _consumer_Received(object? sender, BasicDeliverEventArgs e)
        //{
        //    count++;
        //    var body = e.Body.ToArray();
        //    var message = Encoding.UTF8.GetString(body);

        //    try
        //    {
        //        var obj = JsonConvert.DeserializeObject<RabbitMessagePacket>(message);

        //        if (obj != null)
        //        {
        //            SendSmsMessage(obj.Telephone, obj.Message);
        //        }
        //    }
        //    catch
        //    {

        //    }
        //    finally
        //    {
        //        _channel.BasicAck(e.DeliveryTag, false);
        //        MainThread.BeginInvokeOnMainThread(() =>
        //        {
        //            CounterLabel.Text = $"PROCESSED: {count}";
        //        });
                
        //    }

        //    Thread.Sleep(1000);
        //}
 
        private async void SendSmsMessage(string telephone, string body)
        {
            var sms = new SmsService();
            count++;
            
            var sent = sms.Send(telephone, body);

            await MainThread.InvokeOnMainThreadAsync(() =>
            {
                if (sent)
                {
                    SentLabel.Text = "SENT";
                }
                else
                {
                    SentLabel.Text = "FAILED";
                }
            });
        }
    }

}
