using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tripTicket.Model.Requests
{
    public class UserActivityInsertRequest
    {
        public int UserId { get; set; }

        public string ActionType { get; set; } = null!;

        public DateTime? ActionDate { get; set; }

        public int? TripId { get; set; }

        public string? PurchaseId { get; set; }

        public string? AdditionalInfo { get; set; }
    }
}
