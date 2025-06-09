using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tripTicket.Subscriber.MailSenderService
{
    public interface IMailSenderService
    {
        Task SendEmail(Email emailObj);
    }
}
