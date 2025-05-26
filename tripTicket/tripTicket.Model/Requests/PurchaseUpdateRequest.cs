using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Transactions;

namespace tripTicket.Model.Requests
{
    public class PurchaseUpdateRequest
    {
        public string Status { get; set; } = null!;
    }
}
