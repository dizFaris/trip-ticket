using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tripTicket.Services.Interfaces
{
    public interface IMessageService
    {
        void Publish<T>(T message, string queueName);
    }
}
