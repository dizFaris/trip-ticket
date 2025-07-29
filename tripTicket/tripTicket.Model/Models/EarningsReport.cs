using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tripTicket.Model.Models
{
    public class EarningsReport
    {
        public decimal Total { get; set; }
        public List<EarningsEntry> Data { get; set; } = new();
    }
}
