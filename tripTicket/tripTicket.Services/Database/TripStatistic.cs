using System;
using System.Collections.Generic;

namespace tripTicket.Services.Database;

public partial class TripStatistic
{
    public int TripStatisticsId { get; set; }

    public int TripId { get; set; }

    public int? TotalViews { get; set; }

    public decimal? TotalRevenue { get; set; }

    public decimal? TotalDiscountsApplied { get; set; }

    public int? TotalTicketsSold { get; set; }

    public DateTime? LastUpdated { get; set; }

    public virtual Trip Trip { get; set; } = null!;
}
