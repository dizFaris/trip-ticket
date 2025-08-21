using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;
using tripTicket.Services.Database;
using tripTicket.Services.PurchaseStateMachine;

namespace tripTicket.Services.TripStateMachine
{
    public class UpcomingTripState : BaseTripState
    {
        private readonly BasePurchaseState _basePurchaseState;
        public UpcomingTripState(TripTicketDbContext context, IMapper mapper, IServiceProvider serviceProvider, BasePurchaseState basePurchaseState) : base(context, mapper, serviceProvider)
        {
            _basePurchaseState = basePurchaseState;
        }

        public override async Task<Model.Models.Trip> Cancel(int id)
        {
            var set = Context.Set<Trip>();
            var entity = set.Find(id);

            if (entity == null)
            {
                throw new UserException($"Trip with ID {id} not found.");
            }

            entity.TripStatus = "canceled";
            entity.IsCanceled = true;
            Context.SaveChanges();

            var purchases = Context.Purchases
                   .Where(p => p.TripId == id && p.Status == "accepted")
                   .ToList();

            foreach (var purchase in purchases)
            {
                var state = _basePurchaseState.CreateState(purchase.Status);
                await state.Cancel(purchase.Id);
            }

            return Mapper.Map<Model.Models.Trip>(entity);
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
