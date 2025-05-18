using System;
using System.Collections.Generic;

namespace tripTicket.Services.Database;

public partial class UserActivity
{
    public int UserActivityId { get; set; }

    public int UserId { get; set; }

    public string ActionType { get; set; } = null!;

    public DateTime? ActionDate { get; set; }

    public int? TripId { get; set; }

    public string? PurchaseId { get; set; }

    public string? AdditionalInfo { get; set; }
}
