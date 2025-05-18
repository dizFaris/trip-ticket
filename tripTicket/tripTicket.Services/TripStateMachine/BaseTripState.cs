using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Requests;
using tripTicket.Services.Database;
using Microsoft.Extensions.DependencyInjection;

namespace tripTicket.Services.TripStateMachine
{
    public class BaseTripState
    {
        public TripTicketDbContext Context { get; set; }
        public IMapper Mapper;
        public IServiceProvider ServiceProvider { get; set; }
        public BaseTripState(TripTicketDbContext context, IMapper mapper, IServiceProvider serviceProvider)
        {
            Context = context;
            Mapper = mapper;
            ServiceProvider = serviceProvider;
        }
        public virtual Model.Models.Trip Insert(TripInsertRequest request)
        {
            throw new Exception("Method not allowed");
        }

        public virtual void Cancel(int id)
        {
            throw new Exception("Method not allowed");
        }

        public virtual void LockTrips()
        {
            throw new Exception("Method not allowed");
        }

        public virtual void CompleteTrips()
        {
            throw new Exception("Method not allowed");
        }

        public BaseTripState CreateState(string stateName)
        {
            switch(stateName)
            {
                case "initial":
                    return ServiceProvider.GetService<InitialTripState>();
                case "upcoming":
                    return ServiceProvider.GetService<UpcomingTripState>();
                case "locked":
                    return ServiceProvider.GetService<LockedTripState>();
                case "canceled":
                    throw new Exception("Cannot change canceled trip state");
                default:
                    throw new Exception("State not recognized");
            }
        }
    }
}
