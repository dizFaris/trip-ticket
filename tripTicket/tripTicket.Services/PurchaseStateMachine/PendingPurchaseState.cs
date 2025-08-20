using EasyNetQ;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;
using tripTicket.Model.Messages;
using tripTicket.Model.Models;
using tripTicket.Services.Database;
using tripTicket.Services.Interfaces;
using tripTicket.Services.Services;

namespace tripTicket.Services.PurchaseStateMachine
{
    public class PendingPurchaseState : BasePurchaseState
    {
        private readonly IMessageService _messageService;
        public PendingPurchaseState(TripTicketDbContext context, IMapper mapper, IServiceProvider serviceProvider, IMessageService messageService) : base(context, mapper, serviceProvider)
        {
            _messageService = messageService;
        }

        public override async Task<Model.Models.Purchase> FinalizePurchase(int id, bool paymentSucceeded)
        {
            var purchase = Context.Purchases
                .Include(p => p.User)
                .Include(p => p.Trip)
                    .ThenInclude(t => t.City)
                    .ThenInclude(c => c.Country)
                .FirstOrDefault(p => p.Id == id);

            if (purchase == null)
                throw new UserException("Purchase not found.");

            if (purchase.Status != "pending")
                throw new UserException($"Cannot process payment. Current state: {purchase.Status}");

            if (paymentSucceeded)
            {
                purchase.Status = "accepted";
                Context.SaveChanges();


                PurchaseSuccessful message = new PurchaseSuccessful
                {
                    PurchaseId = purchase.Id,
                    Email = purchase.User.Email,
                    Name = purchase.User.FirstName,
                    DepartureDate = purchase.Trip.DepartureDate,
                    NumberOfTickets = purchase.NumberOfTickets,
                    TotalPayment = purchase.TotalPayment,
                    TripCity = purchase.Trip.City.Name,
                    TripCountry = purchase.Trip.City.Country.Name
                };

                _messageService.Publish(message);

                var recommendationService = new RecommendationService(Context);
                await recommendationService.UpdateUserRecommendationsAsync(purchase.UserId);
            }
            else
            {
                purchase.Status = "failed";
                purchase.Trip.PurchasedTickets -= purchase.NumberOfTickets;
                purchase.Trip.AvailableTickets += purchase.NumberOfTickets;
                Context.SaveChanges();
            }


            return Mapper.Map<Model.Models.Purchase>(purchase);
        }
    }
}
