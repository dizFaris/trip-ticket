using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Transactions;

namespace tripTicket.Model.Models
{
    public class Purchase
    {
        public int Id { get; set; }
        public int TripId { get; set; }

        public int UserId { get; set; }

        public int NumberOfTickets { get; set; }

        public decimal TotalPayment { get; set; }

        public decimal? Discount { get; set; }

        public DateTime CreatedAt { get; set; }

        public string Status { get; set; } = null!;

        public string PaymentMethod { get; set; } = null!;
    }
}
