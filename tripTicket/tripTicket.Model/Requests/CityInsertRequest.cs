using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Models;

namespace tripTicket.Model.Requests
{
    public class CityInsertRequest
    {
        public string Name { get; set; }
        public int CountryId { get; set; }
    }
}
