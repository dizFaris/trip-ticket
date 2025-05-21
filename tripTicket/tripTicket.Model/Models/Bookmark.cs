using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tripTicket.Model.Models
{
    public class Bookmark
    {
        public int Id { get; set; }

        public int UserId { get; set; }

        public int TripId { get; set; }

        public DateTime? CreatedAt { get; set; }

    }
}
