using EasyNetQ;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Services.Interfaces;

namespace tripTicket.Services.Services
{
    public class RabbitMqBus : IMessageService, IDisposable
    {
        private readonly IBus _bus;

        public RabbitMqBus(string connectionString)
        {
            try
            {
                _bus = RabbitHutch.CreateBus(connectionString);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to connect to RabbitMQ: {ex.Message}");
                throw;
            }
        }

        public void Publish<T>(T message)
        {
            try
            {
                _bus.PubSub.Publish(message);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to publish message: {ex.Message}");
            }
        }

        public void Dispose()
        {
            _bus?.Dispose();
        }
    }
}
