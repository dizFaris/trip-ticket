using System;
using System.Collections.Generic;

namespace tripTicket.Services.Database;

public partial class TripDay
{
    public int Id { get; set; }

    public int? TripId { get; set; }

    public int DayNumber { get; set; }

    public string Title { get; set; } = null!;

    public virtual Trip? Trip { get; set; }

    public virtual ICollection<TripDayItem> TripDayItems { get; set; } = new List<TripDayItem>();
}
