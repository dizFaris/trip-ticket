using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tripTicket.Model.Models
{
    public class TripStatistic
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
