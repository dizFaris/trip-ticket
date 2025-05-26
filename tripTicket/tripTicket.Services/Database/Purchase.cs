using System;
using System.Collections.Generic;

namespace tripTicket.Services.Database;

public partial class Purchase
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
    public virtual Trip Trip { get; set; } = null!;

    public virtual ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
}
