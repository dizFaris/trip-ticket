using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Models;

namespace tripTicket.Model.Response
{
    public class PurchaseCancelResponse
    {
        public Purchase Purchase { get; set; }
        public decimal RefundAmount { get; set; }
    }
}
