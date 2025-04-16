using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;

namespace tripTicket.Services
{
    public class TripService : ITripService
    {
        public List<Trip> List = new List<Trip>()
        {
            new Trip ()
            {
                TripId = 1,
                Name = "Kairo",
                Price = 420
            },
            new Trip ()
            {
                TripId = 2,
                Name = "Sri Lanka",
                Price = 720
            }
        };
        public List<Trip> GetList()
        {
            return List;
        }
    }
}
