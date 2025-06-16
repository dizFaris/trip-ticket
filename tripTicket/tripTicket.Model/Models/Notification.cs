using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tripTicket.Model.Models
{
    public class Notification
    {
        public int UserId { get; set; }

        public string Message { get; set; } = null!;

        public DateTime SentAt { get; set; }

        public string Status { get; set; } = null!;

        public virtual User User { get; set; } = null!;
    }
}
