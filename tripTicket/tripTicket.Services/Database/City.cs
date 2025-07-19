using System;
using System.Collections.Generic;

namespace tripTicket.Services.Database;

public partial class City
{
    public int Id { get; set; }
    public string Name { get; set; } = null!;
    public int CountryId { get; set; }
    public bool IsActive { get; set; } = true;

    public virtual Country Country { get; set; } = null!;
    public virtual ICollection<Trip> Trips { get; set; } = new List<Trip>();
}

