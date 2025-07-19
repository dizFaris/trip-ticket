using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static tripTicket.Model.Models.Trip;

namespace tripTicket.Model.Models
{
    public class Country
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;
        public string CountryCode { get; set; } = null!;
    }
}
