using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tripTicket.Services.Database
{
    public partial class TripReview
    {
        public int Id { get; set; }
        public int TripId { get; set; }
        public int UserId { get; set; }
        public int Rating { get; set; }
        public string? Comment { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public virtual Trip Trip { get; set; } = null!;
        public virtual User User { get; set; } = null!;
    }

}
