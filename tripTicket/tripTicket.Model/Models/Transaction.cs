using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tripTicket.Model.Models
{
    public class Transaction
    {
        public string Id { get; set; } = null!;

        public int PurchaseId { get; set; }

        public decimal Amount { get; set; }

        public string Status { get; set; } = null!;

        public string PaymentMethod { get; set; } = null!;

        public DateTime TransactionDate { get; set; }

        public string StripeTransactionId { get; set; } = null!;
    }
}
