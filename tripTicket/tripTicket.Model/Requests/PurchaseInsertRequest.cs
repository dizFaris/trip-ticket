using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Transactions;

namespace tripTicket.Model.Requests
{
    public class PurchaseInsertRequest
    {
        public int TripId { get; set; }

        public int UserId { get; set; }

        public int NumberOfTickets { get; set; }

        public decimal TotalPayment { get; set; }

        public string PaymentMethod { get; set; } = null!;
    }
}
