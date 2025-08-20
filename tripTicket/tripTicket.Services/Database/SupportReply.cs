using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tripTicket.Services.Database
{
    public partial class SupportReply
    {
        public int Id { get; set; }
        public int TicketId { get; set; }
        public string Message { get; set; } = null!;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public virtual SupportTicket Ticket { get; set; } = null!;
    }
}
