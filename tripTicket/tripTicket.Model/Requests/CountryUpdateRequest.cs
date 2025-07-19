using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Models;

namespace tripTicket.Model.Requests
{
    public class CountryUpdateRequest
    {
        public string? Name { get; set; } = null!;
        public string? CountryCode { get; set; } = null!;
        public bool? IsActive { get; set; }
    }
}
