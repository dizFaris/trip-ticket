using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Services.Database;

namespace tripTicket.Services.TripStateMachine
{
    public class LockedTripState : BaseTripState
    {
        public LockedTripState(TripTicketDbContext context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override void CompleteTrips()
        {
            var today = DateOnly.FromDateTime(DateTime.UtcNow);

            var tripsToComplete = Context.Trips
                .Where(t => t.TripStatus == "locked" && t.DepartureDate <= today)
                .ToList();

            foreach (var trip in tripsToComplete)
            {
                trip.TripStatus = "complete";
            }

            Context.SaveChanges();
        }
    }
}
