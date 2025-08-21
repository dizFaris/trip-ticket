using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Requests;
using tripTicket.Services.Database;
using Microsoft.Extensions.DependencyInjection;
using tripTicket.Model;

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
            throw new UserException("Method not allowed");
        }

        public virtual Task<Model.Models.Trip> Cancel(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual void LockTrips()
        {
            throw new UserException("Method not allowed");
        }

        public virtual void CompleteTrips()
        {
            throw new UserException("Method not allowed");
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
                    throw new UserException("Cannot change canceled trip state");
                case "complete":
                    throw new UserException("Cannot cancel a completed trip");
                default:
                    throw new UserException("State not recognized");
            }
        }
    }
}
