using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
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

        public void UpdateTripStatuses()
        {
            var upcomingState = _serviceProvider.GetRequiredService<UpcomingTripState>();
            var lockedState = _serviceProvider.GetRequiredService<LockedTripState>();

            upcomingState.LockTrips();
            lockedState.CompleteTrips();
        }
    }
}
