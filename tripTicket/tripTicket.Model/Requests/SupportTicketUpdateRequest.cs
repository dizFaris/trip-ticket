using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Models;

namespace tripTicket.Model.Requests
{
    public class SupportTicketUpdateRequest
    {
        public string Status { get; set; }
        public DateTime ResolvedAt { get; set; }
    }
}
