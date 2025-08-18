using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tripTicket.Services.Messages
{
    public class PurchaseExpired
    {
        public int PurchaseId { get; set; }
        public string Email { get; set; } = null!;
        public string Name { get; set; } = null!;
        public int NumberOfTickets { get; set; }
        public decimal TotalPayment { get; set; }
        public string TripCity { get; set; } = null!;
        public string TripCountry { get; set; } = null!;
        public DateOnly DepartureDate { get; set; }
    }
}
