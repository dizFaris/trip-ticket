using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;
using tripTicket.Services.Database;

namespace tripTicket.Services.PurchaseStateMachine
{
    public class AcceptedPurchaseState : BasePurchaseState
    {
        public AcceptedPurchaseState(TripTicketDbContext context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override Model.Models.Purchase Cancel(int id)
        {
            var set = Context.Set<Purchase>();
            var entity = set.Find(id);

            if (entity == null)
            {
                throw new UserException($"Purchase with ID {id} not found.");
            }

            entity.Status = "canceled";
            Context.SaveChanges();

            return Mapper.Map<Model.Models.Purchase>(entity);
        }

        public override Model.Models.Purchase Complete(int id)
        {
            var set = Context.Set<Purchase>();
            var entity = set.Find(id);

            if (entity == null)
            {
                throw new UserException($"Purchase with ID {id} not found.");
            }

            entity.Status = "complete";
            Context.SaveChanges();

            return Mapper.Map<Model.Models.Purchase>(entity);
        }

        public override void ExpirePurchases()
        {
            var today = DateOnly.FromDateTime(DateTime.UtcNow);

            var purchasesToComplete = Context.Purchases.Include(p => p.Trip)
                .Where(t => t.Status == "accepted" && t.Trip.DepartureDate <= today)
                .ToList();

            foreach (var purchase in purchasesToComplete)
            {
                purchase.Status = "expired";
            }

            Context.SaveChanges();
        }
    }
}
