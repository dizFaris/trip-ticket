using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tripTicket.Model.Requests
{
    public class TripInsertRequest
    {
        public string City { get; set; }

        public string Country { get; set; }

        public string DepartureCity { get; set; }

        public DateOnly DepartureDate { get; set; }

        public DateOnly ReturnDate { get; set; }

        public string? TripType { get; set; }

        public string? TransportType { get; set; }

        public decimal TicketPrice { get; set; }

        public int AvailableTickets { get; set; }

        public string? Description { get; set; }

        public DateOnly? FreeCancellationUntil { get; set; }

        public decimal? CancellationFee { get; set; }

        public int? MinTicketsForDiscount { get; set; }

        public decimal? DiscountPercentage { get; set; }

        public byte[]? Photo { get; set; }
        public List<TripDayInsertRequest> TripDays { get; set; } = new();
        public class TripDayInsertRequest
        {
            public int DayNumber { get; set; }
            public string Title { get; set; } = null!;
            public List<TripDayItemInsertRequest> TripDayItems { get; set; } = new();
        }

        public class TripDayItemInsertRequest
        {
            public TimeOnly Time { get; set; }
            public string Action { get; set; } = null!;
            public int OrderNumber { get; set; }
        }
    }
}
