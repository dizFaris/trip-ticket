using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Models;

namespace tripTicket.Model.Requests
{
    public class TripStatisticUpdateRequest
    {
        public int Id { get; set; }

        public int TripId { get; set; }

        public int? TotalViews { get; set; }

        public decimal? TotalRevenue { get; set; }

        public decimal? TotalDiscountsApplied { get; set; }

        public int? TotalTicketsSold { get; set; }

        public DateTime? LastUpdated { get; set; }

        public virtual Trip Trip { get; set; } = null!;
    }
}
