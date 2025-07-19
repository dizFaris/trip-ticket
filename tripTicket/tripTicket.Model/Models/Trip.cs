using System;
using System.Collections.Generic;

namespace tripTicket.Model.Models
{
    public class Trip
    {
        public int Id { get; set; }

        public int CityId { get; set; }
        public int DepartureCityId { get; set; }
        public virtual City City { get; set; } = null!;
        public virtual City DepartureCity { get; set; } = null!;

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

        public string TripStatus { get; set; }

        public bool IsCanceled { get; set; }

        public DateTime CreatedAt { get; set; }

        public List<TripDayRequest> TripDays { get; set; } = new();

        public class TripDayRequest
        {
            public int DayNumber { get; set; }

            public string Title { get; set; } = null!;

            public List<TripDayItemRequest> TripDayItems { get; set; } = new();
        }

        public class TripDayItemRequest
        {
            public TimeOnly Time { get; set; }

            public string Action { get; set; } = null!;

            public int OrderNumber { get; set; }
        }
    }
}
