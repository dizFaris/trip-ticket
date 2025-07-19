using Azure.Core;
using EasyNetQ;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;
using tripTicket.Model.Models;
using tripTicket.Services.Database;
using tripTicket.Services.Messages;

namespace tripTicket.Services.PurchaseStateMachine
{
    public class AcceptedPurchaseState : BasePurchaseState
    {
        public AcceptedPurchaseState(TripTicketDbContext context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override Model.Models.Purchase Cancel(int id)
        {
            var set = Context.Set<Database.Purchase>();
            var entity = set.Find(id);

            if (entity == null)
            {
                throw new UserException($"Purchase with ID {id} not found.");
            }

            entity.Status = "canceled";
            Context.SaveChanges();

            var user = Context.Users.Find(entity.UserId);
            var trip = Context.Trips.Find(entity.TripId);

            var bus = RabbitHutch.CreateBus("host=localhost");
            var purchase = Mapper.Map<Model.Models.Purchase>(entity);

            PurchaseCanceled message = new PurchaseCanceled
            {
                PurchaseId = entity.Id,
                Email = user.Email,
                Name = user.FirstName,
                RefundAmount = entity.TotalPayment - (trip.CancellationFee ?? 0m)
            };

            bus.PubSub.Publish(message);

            return purchase;
        }

        public override Model.Models.Purchase Complete(int id)
        {
            var set = Context.Set<Database.Purchase>();
            var entity = set.Find(id);

            if (entity == null)
            {
                throw new UserException($"Purchase with ID {id} not found.");
            }

            entity.Status = "complete";
            Context.SaveChanges();


            var user = Context.Users.Find(entity.UserId);
            var trip = Context.Trips.Find(entity.TripId);

            var bus = RabbitHutch.CreateBus("host=localhost");
            var purchase = Mapper.Map<Model.Models.Purchase>(entity);

            PurchaseCompleted message = new PurchaseCompleted
            {
                PurchaseId = entity.Id,
                Email = user.Email,
                Name = user.FirstName,
                DepartureDate = trip.DepartureDate,
                NumberOfTickets = entity.NumberOfTickets,
                TotalPayment = entity.TotalPayment,
                TripCity = trip.City.Name,
                TripCountry = trip.City.Country.Name
            };

            bus.PubSub.Publish(message);

            return Mapper.Map<Model.Models.Purchase>(entity);
        }

        public override void ExpirePurchases()
        {
            var today = DateOnly.FromDateTime(DateTime.UtcNow);

            var purchasesToExpire = Context.Purchases.Include(p => p.Trip)
                .Where(t => t.Status == "accepted" && t.Trip.DepartureDate <= today)
                .ToList();

            foreach (var purchase in purchasesToExpire)
            {
                purchase.Status = "expired";

                var user = Context.Users.Find(purchase.UserId);
                var trip = Context.Trips.Find(purchase.TripId);

                var bus = RabbitHutch.CreateBus("host=localhost");

                PurchaseExpired message = new PurchaseExpired
                {
                    PurchaseId = purchase.Id,
                    Email = user.Email,
                    Name = user.FirstName,
                };

                bus.PubSub.Publish(message);
            }

            Context.SaveChanges();
        }
    }
}
