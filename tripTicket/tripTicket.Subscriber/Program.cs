using EasyNetQ;
using tripTicket.Services.Messages;
using tripTicket.Subscriber.MailSenderService;
using DotNetEnv;
using tripTicket.Subscriber;

Console.WriteLine("Starting TripTicket Mail Listener...");
Env.Load();

var mailSender = new MailSenderService();

var purchaseTemplatePath = Path.Combine(AppContext.BaseDirectory, "Templates", "PurchaseSuccessful.html");
var purchaseTemplate = await File.ReadAllTextAsync(purchaseTemplatePath);

var canceledTemplatePath = Path.Combine(AppContext.BaseDirectory, "Templates", "PurchaseCanceled.html");
var canceledTemplate = await File.ReadAllTextAsync(canceledTemplatePath);

var expiredTemplatePath = Path.Combine(AppContext.BaseDirectory, "Templates", "PurchaseExpired.html");
var expiredTemplate = await File.ReadAllTextAsync(expiredTemplatePath);

var completeTemplatePath = Path.Combine(AppContext.BaseDirectory, "Templates", "PurchaseComplete.html");
var completeTemplate = await File.ReadAllTextAsync(completeTemplatePath);

var bus = RabbitHutch.CreateBus("host=localhost");

await bus.PubSub.SubscribeAsync<PurchaseSuccessful>("trip_service", async msg =>
{
    Console.WriteLine($"Purchase successful. Purchase ID: {msg.PurchaseId}");

    var filledHtml = purchaseTemplate
        .Replace("{{Name}}", msg.Name)
        .Replace("{{PurchaseId}}", msg.PurchaseId.ToString())
        .Replace("{{TripCity}}", msg.TripCity)
        .Replace("{{TripCountry}}", msg.TripCountry)
        .Replace("{{DepartureDate}}", msg.DepartureDate.ToString("yyyy-MM-dd"))
        .Replace("{{NumberOfTickets}}", msg.NumberOfTickets.ToString())
        .Replace("{{TotalPayment}}", msg.TotalPayment.ToString("F2"));

    var email = new Email
    {
        EmailTo = msg.Email,
        ReceiverName = msg.Name ?? "Customer",
        Subject = "Your TripTicket Purchase is Confirmed!",
        Message = filledHtml
    };

    await mailSender.SendEmail(email);
});

await bus.PubSub.SubscribeAsync<PurchaseCanceled>("trip_service_cancel", async msg =>
{
    Console.WriteLine($"Purchase canceled. Purchase ID: {msg.PurchaseId}");

    var filledHtml = canceledTemplate
        .Replace("{{Name}}", msg.Name)
        .Replace("{{PurchaseId}}", msg.PurchaseId.ToString())
        .Replace("{{RefundAmount}}", msg.RefundAmount.ToString("F2"));

    var email = new Email
    {
        EmailTo = msg.Email,
        ReceiverName = msg.Name ?? "Customer",
        Subject = "Your TripTicket Purchase Has Been Canceled",
        Message = filledHtml
    };

    await mailSender.SendEmail(email);
});

await bus.PubSub.SubscribeAsync<PurchaseExpired>("trip_service_expire", async msg =>
{
    Console.WriteLine($"Purchase expired. Purchase ID: {msg.PurchaseId}");

    var filledHtml = expiredTemplate
        .Replace("{{Name}}", msg.Name)
        .Replace("{{PurchaseId}}", msg.PurchaseId.ToString());

    var email = new Email
    {
        EmailTo = msg.Email,
        ReceiverName = msg.Name ?? "Customer",
        Subject = "Your TripTicket Purchase Has Expired",
        Message = filledHtml
    };

    await mailSender.SendEmail(email);
});

await bus.PubSub.SubscribeAsync<PurchaseCompleted>("trip_service_complete", async msg =>
{
    Console.WriteLine($"Purchase complete. Purchase ID: {msg.PurchaseId}");

    var filledHtml = completeTemplate
        .Replace("{{Name}}", msg.Name)
        .Replace("{{PurchaseId}}", msg.PurchaseId.ToString())
        .Replace("{{TripCity}}", msg.TripCity)
        .Replace("{{TripCountry}}", msg.TripCountry)
        .Replace("{{DepartureDate}}", msg.DepartureDate.ToString("yyyy-MM-dd"))
        .Replace("{{NumberOfTickets}}", msg.NumberOfTickets.ToString())
        .Replace("{{TotalPayment}}", msg.TotalPayment.ToString("F2"));

    var email = new Email
    {
        EmailTo = msg.Email,
        ReceiverName = msg.Name ?? "Customer",
        Subject = "Your TripTicket Purchase is Complete",
        Message = filledHtml
    };

    await mailSender.SendEmail(email);
});

Console.WriteLine("Listening for messages... Press <return> to exit.");
Console.ReadLine();
