﻿using System;
using System.Collections.Generic;

namespace tripTicket.Services.Database;
public partial class Country
{
    public int Id { get; set; }
    public string Name { get; set; } = null!;
    public string CountryCode { get; set; } = null!;
    public bool IsActive { get; set; } = true;

    public virtual ICollection<City> Cities { get; set; } = new List<City>();
}


