using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Models;

namespace tripTicket.Model.Requests
{
    public class TransactionInsertRequest
    {
        public int PurchaseId { get; set; }

        public decimal Amount { get; set; }
        public string PaymentMethod { get; set; } = null!;
        public string Type { get; set; } = null!;
        public string Status { get; set; } = null!;

        public DateTime TransactionDate { get; set; }

        public string StripeTransactionId { get; set; } = null!;
    }
}
