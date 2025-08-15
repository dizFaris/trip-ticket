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
    public class PendingPurchaseState : BasePurchaseState
    {
        public PendingPurchaseState(TripTicketDbContext context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override Model.Models.Purchase FinalizePurchase(int id, bool paymentSucceeded)
        {
            var purchaseEntity = Context.Purchases
                .Include(p => p.User)
                .Include(p => p.Trip)
                    .ThenInclude(t => t.City)
                    .ThenInclude(c => c.Country)
                .FirstOrDefault(p => p.Id == id);

            if (purchaseEntity == null)
                throw new UserException("Purchase not found.");

            if (purchaseEntity.Status != "pending")
                throw new UserException($"Cannot process payment. Current state: {purchaseEntity.Status}");

            if (paymentSucceeded)
            {
                purchaseEntity.Status = "accepted";
            }
            else
            {
                purchaseEntity.Status = "failed";
                purchaseEntity.Trip.PurchasedTickets -= purchaseEntity.NumberOfTickets;
                purchaseEntity.Trip.AvailableTickets += purchaseEntity.NumberOfTickets;
            }

            Context.SaveChanges();

            return Mapper.Map<Model.Models.Purchase>(purchaseEntity);
        }
    }
}
