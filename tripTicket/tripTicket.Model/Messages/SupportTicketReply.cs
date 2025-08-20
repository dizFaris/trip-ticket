using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tripTicket.Model.Messages
{
    public class SupportTicketReply
    {
        public int TicketId { get; set; }
        public string Email { get; set; } = null!;
        public string Name { get; set; } = null!;
        public string Subject {  get; set; } = null!;
        public string Message { get; set; } = null!;
    }
}
