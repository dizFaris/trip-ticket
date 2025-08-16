using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tripTicket.Model.SearchObjects
{
    public class TransactionSearchObject : BaseSearchObject
    {
        public string? FTS { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
        public decimal? MinAmount { get; set; }
        public decimal? MaxAmount { get; set; }
        public string? Status { get; set; }
        public string? Type { get; set; }
    }
}
