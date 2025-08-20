using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tripTicket.Model.Requests
{
    public class TripUpdateRequest
    {
        public int CityId { get; set; }
        public int DepartureCityId { get; set; }

        public DateOnly DepartureDate { get; set; }

        public DateOnly ReturnDate { get; set; }

        public string TripType { get; set; }

        public string TransportType { get; set; }

        public string Description { get; set; }

        public DateOnly? FreeCancellationUntil { get; set; }
        public int AvailableTickets { get; set; }

        public byte[]? Photo { get; set; }

        public List<TripDayUpdateRequest> TripDays { get; set; } = new();

        public class TripDayUpdateRequest
        {
            public int DayNumber { get; set; }
            public string Title { get; set; } = null!;
            public List<TripDayItemUpdateRequest> TripDayItems { get; set; } = new();
        }

        public class TripDayItemUpdateRequest
        {
            public TimeOnly Time { get; set; }
            public string Action { get; set; } = null!;
            public int OrderNumber { get; set; }
        }
    }
}
