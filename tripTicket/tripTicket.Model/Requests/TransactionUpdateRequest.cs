using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Models;

namespace tripTicket.Model.Requests
{
    public class TransactionUpdateRequest
    {
        public string Id { get; set; } = null!;
        public string PaymentMethod { get; set; } = null!;
    }
}
