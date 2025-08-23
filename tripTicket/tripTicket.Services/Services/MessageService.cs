using Newtonsoft.Json;
using RabbitMQ.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Services.Interfaces;

namespace tripTicket.Services.Services
{
    public class MessageService :  IMessageService
    {
        private readonly string _hostname = Environment.GetEnvironmentVariable("_rabbitMqHost") ?? "localhost";
        private readonly string _username = Environment.GetEnvironmentVariable("_rabbitMqUser") ?? "guest";
        private readonly string _password = Environment.GetEnvironmentVariable("_rabbitMqPassword") ?? "guest";
        private readonly int _port = int.Parse(Environment.GetEnvironmentVariable("_rabbitMqPort") ?? "5672");

        public void Publish<T>(T message, string queueName)
        {
            try
            {
                var factory = new ConnectionFactory()
                {
                    HostName = _hostname,
                    UserName = _username,
                    Password = _password,
                    Port = _port
                };

                using var connection = factory.CreateConnection();
                using var channel = connection.CreateModel();

                channel.QueueDeclare(queue: queueName, durable: false, exclusive: false, autoDelete: false, arguments: null);

                var body = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(message));

                channel.BasicPublish(exchange: "", routingKey: queueName, basicProperties: null, body: body);

                Console.WriteLine($"Message sent to queue {queueName}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to publish message: {ex.Message}");
            }
        }
    }
}
