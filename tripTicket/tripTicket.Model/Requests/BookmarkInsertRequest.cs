using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Models;

namespace tripTicket.Model.Requests
{
    public class BookmarkInsertRequest
    {
        public int UserId { get; set; }

        public int TripId { get; set; }
    }
}
