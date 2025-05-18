using System;
using System.Collections.Generic;

namespace tripTicket.Services.Database;

public partial class TripDayItem
{
    public int Id { get; set; }

    public int? TripDayId { get; set; }

    public TimeOnly Time { get; set; }

    public string Action { get; set; } = null!;

    public int OrderNumber { get; set; }

    public virtual TripDay? TripDay { get; set; }
}
