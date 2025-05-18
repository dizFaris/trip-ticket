using System;
using System.Collections.Generic;

namespace tripTicket.Services.Database;

public partial class Bookmark
{
    public int BookmarkId { get; set; }

    public int UserId { get; set; }

    public int TripId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual Trip Trip { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
