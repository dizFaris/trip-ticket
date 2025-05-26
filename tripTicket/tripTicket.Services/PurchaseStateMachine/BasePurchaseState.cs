using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Requests;
using tripTicket.Model;
using tripTicket.Services.Database;
using tripTicket.Services.TripStateMachine;

namespace tripTicket.Services.PurchaseStateMachine
{
    public class BasePurchaseState
    {
        public TripTicketDbContext Context { get; set; }
        public IMapper Mapper;
        public IServiceProvider ServiceProvider { get; set; }
        public BasePurchaseState(TripTicketDbContext context, IMapper mapper, IServiceProvider serviceProvider)
        {
            Context = context;
            Mapper = mapper;
            ServiceProvider = serviceProvider;
        }
        public virtual Model.Models.Purchase Insert(PurchaseInsertRequest request)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Model.Models.Purchase Cancel(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Model.Models.Purchase Complete(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual void ExpirePurchases()
        {
            throw new UserException("Method not allowed");
        }

        public BasePurchaseState CreateState(string stateName)
        {
            switch (stateName)
            {
                case "initial":
                    return ServiceProvider.GetService<InitialPurchaseState>();
                case "accepted":
                    return ServiceProvider.GetService<AcceptedPurchaseState>();
                case "expired":
                    throw new UserException("Cannot change expired purchase state");
                case "canceled":
                    throw new UserException("Cannot change canceled purchase state");
                case "complete":
                    throw new UserException("Cannot cancel a completed purchase");
                default:
                    throw new UserException("State not recognized");
            }
        }
    }
}
