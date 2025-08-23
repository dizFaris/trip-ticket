using DotNetEnv;
using tripTicket.Subscriber.MailSenderService;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using Newtonsoft.Json;
using tripTicket.Model.Messages;
using tripTicket.Subscriber;

Env.Load();
var mailSender = new MailSenderService();

Console.WriteLine("Starting TripTicket Mail Listener...");

var purchaseTemplatePath = Path.Combine(AppContext.BaseDirectory, "Templates", "PurchaseSuccessful.html");
var canceledTemplatePath = Path.Combine(AppContext.BaseDirectory, "Templates", "PurchaseCanceled.html");
var expiredTemplatePath = Path.Combine(AppContext.BaseDirectory, "Templates", "PurchaseExpired.html");
var completeTemplatePath = Path.Combine(AppContext.BaseDirectory, "Templates", "PurchaseComplete.html");
var supportTicketReplyTemplatePath = Path.Combine(AppContext.BaseDirectory, "Templates", "SupportTicketReply.html");

var purchaseTemplate = await File.ReadAllTextAsync(purchaseTemplatePath);
var canceledTemplate = await File.ReadAllTextAsync(canceledTemplatePath);
var expiredTemplate = await File.ReadAllTextAsync(expiredTemplatePath);
var completeTemplate = await File.ReadAllTextAsync(completeTemplatePath);
var supportTicketReplyTemplate = await File.ReadAllTextAsync(supportTicketReplyTemplatePath);

var factory = new ConnectionFactory()
{
    HostName = Environment.GetEnvironmentVariable("_rabbitMqHost") ?? "localhost",
    UserName = Environment.GetEnvironmentVariable("_rabbitMqUser") ?? "guest",
    Password = Environment.GetEnvironmentVariable("_rabbitMqPassword") ?? "guest",
    Port = int.Parse(Environment.GetEnvironmentVariable("_rabbitMqPort") ?? "5672")
};

using var connection = factory.CreateConnection();
using var channel = connection.CreateModel();

string[] queues = { "trip_service", "trip_service_cancel", "trip_service_expire", "trip_service_complete", "trip_service_support_ticket" };
foreach (var q in queues)
{
    channel.QueueDeclare(queue: q, durable: false, exclusive: false, autoDelete: false, arguments: null);
}

var consumer = new EventingBasicConsumer(channel);
consumer.Received += async (sender, args) =>
{
    var messageBody = Encoding.UTF8.GetString(args.Body.ToArray());
    try
    {
        switch (args.RoutingKey)
        {
            case "trip_service":
                var purchase = JsonConvert.DeserializeObject<PurchaseSuccessful>(messageBody);
                if (purchase != null)
                {
                    Console.WriteLine($"Purchase successful: {purchase.PurchaseId}");
                    var filledHtml = purchaseTemplate
                        .Replace("{{Name}}", purchase.Name)
                        .Replace("{{PurchaseId}}", purchase.PurchaseId.ToString())
                        .Replace("{{TripCity}}", purchase.TripCity)
                        .Replace("{{TripCountry}}", purchase.TripCountry)
                        .Replace("{{DepartureDate}}", purchase.DepartureDate.ToString("yyyy-MM-dd"))
                        .Replace("{{NumberOfTickets}}", purchase.NumberOfTickets.ToString())
                        .Replace("{{TotalPayment}}", purchase.TotalPayment.ToString("F2"));

                    var email = new Email
                    {
                        EmailTo = purchase.Email,
                        ReceiverName = purchase.Name ?? "Customer",
                        Subject = "Your TripTicket Purchase is Confirmed!",
                        Message = filledHtml
                    };
                    await mailSender.SendEmail(email);
                }
                break;

            case "trip_service_cancel":
                var canceled = JsonConvert.DeserializeObject<PurchaseCanceled>(messageBody);
                if (canceled != null)
                {
                    Console.WriteLine($"Purchase canceled: {canceled.PurchaseId}");
                    var filledHtml = canceledTemplate
                        .Replace("{{Name}}", canceled.Name)
                        .Replace("{{PurchaseId}}", canceled.PurchaseId.ToString())
                        .Replace("{{RefundAmount}}", canceled.RefundAmount.ToString("F2"))
                        .Replace("{{TripCity}}", canceled.TripCity)
                        .Replace("{{TripCountry}}", canceled.TripCountry)
                        .Replace("{{DepartureDate}}", canceled.DepartureDate.ToString("yyyy-MM-dd"))
                        .Replace("{{NumberOfTickets}}", canceled.NumberOfTickets.ToString())
                        .Replace("{{TotalPayment}}", canceled.TotalPayment.ToString("F2"));

                    var email = new Email
                    {
                        EmailTo = canceled.Email,
                        ReceiverName = canceled.Name ?? "Customer",
                        Subject = "Your TripTicket Purchase Has Been Canceled",
                        Message = filledHtml
                    };
                    await mailSender.SendEmail(email);
                }
                break;

            case "trip_service_expire":
                var expired = JsonConvert.DeserializeObject<PurchaseExpired>(messageBody);
                if (expired != null)
                {
                    Console.WriteLine($"Purchase expired: {expired.PurchaseId}");
                    var filledHtml = expiredTemplate
                        .Replace("{{Name}}", expired.Name)
                        .Replace("{{PurchaseId}}", expired.PurchaseId.ToString())
                        .Replace("{{TripCity}}", expired.TripCity)
                        .Replace("{{TripCountry}}", expired.TripCountry)
                        .Replace("{{DepartureDate}}", expired.DepartureDate.ToString("yyyy-MM-dd"))
                        .Replace("{{NumberOfTickets}}", expired.NumberOfTickets.ToString())
                        .Replace("{{TotalPayment}}", expired.TotalPayment.ToString("F2"));

                    var email = new Email
                    {
                        EmailTo = expired.Email,
                        ReceiverName = expired.Name ?? "Customer",
                        Subject = "Your TripTicket Purchase Has Expired",
                        Message = filledHtml
                    };
                    await mailSender.SendEmail(email);
                }
                break;

            case "trip_service_complete":
                var complete = JsonConvert.DeserializeObject<PurchaseCompleted>(messageBody);
                if (complete != null)
                {
                    Console.WriteLine($"Purchase complete: {complete.PurchaseId}");
                    var filledHtml = completeTemplate
                        .Replace("{{Name}}", complete.Name)
                        .Replace("{{PurchaseId}}", complete.PurchaseId.ToString())
                        .Replace("{{TripCity}}", complete.TripCity)
                        .Replace("{{TripCountry}}", complete.TripCountry)
                        .Replace("{{DepartureDate}}", complete.DepartureDate.ToString("yyyy-MM-dd"))
                        .Replace("{{NumberOfTickets}}", complete.NumberOfTickets.ToString())
                        .Replace("{{TotalPayment}}", complete.TotalPayment.ToString("F2"));

                    var email = new Email
                    {
                        EmailTo = complete.Email,
                        ReceiverName = complete.Name ?? "Customer",
                        Subject = "Your TripTicket Purchase is Complete",
                        Message = filledHtml
                    };
                    await mailSender.SendEmail(email);
                }
                break;

            case "trip_service_support_ticket":
                var reply = JsonConvert.DeserializeObject<SupportTicketReply>(messageBody);
                if (reply != null)
                {
                    Console.WriteLine($"Support ticket reply: {reply.TicketId}");
                    var filledHtml = supportTicketReplyTemplate
                        .Replace("{{Name}}", reply.Name)
                        .Replace("{{TicketId}}", reply.TicketId.ToString())
                        .Replace("{{Subject}}", reply.Subject)
                        .Replace("{{Message}}", reply.Message);

                    var email = new Email
                    {
                        EmailTo = reply.Email,
                        ReceiverName = reply.Name ?? "Customer",
                        Subject = "Trip Ticket Support Reply",
                        Message = filledHtml
                    };
                    await mailSender.SendEmail(email);
                }
                break;

            default:
                Console.WriteLine($"Unknown routing key: {args.RoutingKey}");
                break;
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error processing message from queue {args.RoutingKey}: {ex}");
    }
};

foreach (var q in queues)
{
    channel.BasicConsume(queue: q, autoAck: true, consumer: consumer);
}

Console.WriteLine("Listening for all messages...");
Thread.Sleep(Timeout.Infinite);
