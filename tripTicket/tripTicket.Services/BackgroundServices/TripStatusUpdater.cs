using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Services.PurchaseStateMachine;
using tripTicket.Services.TripStateMachine;

namespace tripTicket.Services.BackgroundServices
{
    public class TripStatusUpdater
    {
        private readonly IServiceProvider _serviceProvider;

        public TripStatusUpdater(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        public void UpdateTripsAndPurchases()
        {
            var upcomingTripState = _serviceProvider.GetRequiredService<UpcomingTripState>();
            var lockedTripState = _serviceProvider.GetRequiredService<LockedTripState>();
            var acceptedPurchaseState = _serviceProvider.GetRequiredService<AcceptedPurchaseState>();

            upcomingTripState.LockTrips();
            lockedTripState.CompleteTrips();
            acceptedPurchaseState.ExpirePurchases();
        }
    }
}
