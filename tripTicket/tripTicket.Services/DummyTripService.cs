using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;

namespace tripTicket.Services
{
    public class DummyTripService : ITripService
    {
        public List<Trip> List = new List<Trip>()
        {
            new Trip ()
            {
                TripId = 1,
                Name = "Kairo",
                Price = 420
            },
        };
        public List<Trip> GetList()
        {
            return List;
        }
    }
}
