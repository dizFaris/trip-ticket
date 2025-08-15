using System;
using System.Collections.Generic;

namespace tripTicket.Services.Database;

public partial class Transaction
{
    public int Id { get; set; }

    public int PurchaseId { get; set; }

    public decimal Amount { get; set; }

    public string Status { get; set; } = null!;

    public string PaymentMethod { get; set; } = null!;

    public DateTime TransactionDate { get; set; }

    public string StripeTransactionId { get; set; } = null!;

    public virtual Purchase Purchase { get; set; }  = null!;
}
