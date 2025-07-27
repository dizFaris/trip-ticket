using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tripTicket.Model.SearchObjects
{
    public class UserSearchObject : BaseSearchObject
    {
        public string? FTS { get; set; }
        public DateOnly? FromDate { get; set; }
        public DateOnly? ToDate { get; set; }
        public bool? IsActive { get; set; }
    }
}
