using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;
using tripTicket.Services.Database;

namespace tripTicket.Services.TripStateMachine
{
    public class UpcomingTripState : BaseTripState
    {
        public UpcomingTripState(TripTicketDbContext context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override void Cancel(int id)
        {
            var set = Context.Set<Trip>();
            var entity = set.Find(id);

            if (entity == null)
            {
                throw new Exception($"Trip with ID {id} not found.");
            }

            entity.TripStatus = "canceled";
            entity.IsCanceled = true;
            Context.SaveChanges();
        }

        public override void LockTrips()
        {
            var now = DateTime.UtcNow;

            var tripsToLock = Context.Trips
                .Where(t => t.TripStatus == "upcoming" && t.TicketSaleEnd < now)
                .ToList();

            foreach (var trip in tripsToLock)
            {
                trip.TripStatus = "locked";
            }

            Context.SaveChanges();
        }
    }
}
