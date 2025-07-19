using System;
using System.Collections.Generic;

namespace tripTicket.Services.Database;

public partial class Trip
{
    public int Id { get; set; }

    public int CityId { get; set; }

    public int DepartureCityId { get; set; }

    public DateOnly DepartureDate { get; set; }

    public DateOnly ReturnDate { get; set; }

    public DateTime TicketSaleEnd { get; set; }

    public string? TripType { get; set; }

    public string? TransportType { get; set; }

    public decimal TicketPrice { get; set; }

    public int AvailableTickets { get; set; }

    public int PurchasedTickets { get; set; }

    public string? Description { get; set; }

    public DateOnly? FreeCancellationUntil { get; set; }

    public decimal? CancellationFee { get; set; }

    public int? MinTicketsForDiscount { get; set; }

    public decimal? DiscountPercentage { get; set; }

    public byte[]? Photo { get; set; }

    public string TripStatus { get; set; } = null!;

    public bool IsCanceled { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual City City { get; set; } = null!;
    public virtual City DepartureCity { get; set; } = null!;

    public virtual ICollection<Bookmark> Bookmarks { get; set; } = new List<Bookmark>();

    public virtual ICollection<TripDay> TripDays { get; set; } = new List<TripDay>();

    public virtual ICollection<TripStatistic> TripStatistics { get; set; } = new List<TripStatistic>();
    public virtual ICollection<Purchase> TripPurchases { get; set; } = new List<Purchase>();
}
