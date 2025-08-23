using Azure.Core;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;
using tripTicket.Model.Messages;
using tripTicket.Model.Models;
using tripTicket.Model.Response;
using tripTicket.Services.Database;
using tripTicket.Services.Interfaces;

namespace tripTicket.Services.PurchaseStateMachine
{
    public class AcceptedPurchaseState : BasePurchaseState
    {
        private readonly IMessageService _messageService;

        public AcceptedPurchaseState(TripTicketDbContext context, IMapper mapper, IServiceProvider serviceProvider, IMessageService messageService) : base(context, mapper, serviceProvider)
        {
            _messageService = messageService;
        }

        public override async Task<PurchaseCancelResponse> Cancel(int id)
        {
            var entity = Context.Purchases
                .Include(p => p.User)
                .Include(p => p.Trip)
                    .ThenInclude(t => t.City)
                    .ThenInclude(c => c.Country)
                .FirstOrDefault(p => p.Id == id);

            if (entity == null)
            {
                throw new UserException($"Purchase with ID {id} not found.");
            }

            entity.Status = "canceled";
            Context.SaveChanges();

            var user = Context.Users.Find(entity.UserId);
            var trip = Context.Trips.Find(entity.TripId);

            // Calculate refund
            decimal refundAmount;
            var today = DateOnly.FromDateTime(DateTime.UtcNow);

            if (!trip.FreeCancellationUntil.HasValue || today <= trip.FreeCancellationUntil.Value)
            {
                refundAmount = entity.TotalPayment;
            }
            else
            {
                var feePercentage = trip.CancellationFee ?? 0m;
                refundAmount = entity.TotalPayment - (entity.TotalPayment * feePercentage / 100);
            }

            var transaction = Context.Transactions.FirstOrDefault(t => t.PurchaseId == entity.Id);
            var transactionService = ServiceProvider.GetService<ITransactionService>();

            string refundStatus = "failed";
            string refundStripeId = string.Empty;


            if (transaction != null && !string.IsNullOrEmpty(transaction.StripeTransactionId))
            {
                try
                {
                    var refund = await transactionService.RefundTransactionAsync(transaction.StripeTransactionId, refundAmount);
                    refundStatus = refund.Status == "succeeded" ? "complete" : "failed";
                    refundStripeId = refund.Id;
                }
                catch (Exception ex)
                {
                    refundStatus = "failed";
                    refundStripeId = transaction.StripeTransactionId;
                    refundAmount = 0;
                }

                var refundTransaction = new Database.Transaction
                {
                    PurchaseId = entity.Id,
                    Amount = refundAmount,
                    Status = refundStatus,
                    PaymentMethod = "Stripe",
                    Type = "Refund",
                    TransactionDate = DateTime.UtcNow,
                    StripeTransactionId = refundStripeId
                };

                Context.Transactions.Add(refundTransaction);
                Context.SaveChanges();

                PurchaseCanceled message = new PurchaseCanceled
                {
                    PurchaseId = entity.Id,
                    Email = user.Email,
                    Name = user.FirstName,
                    RefundAmount = refundAmount,
                    DepartureDate = entity.Trip.DepartureDate,
                    NumberOfTickets = entity.NumberOfTickets,
                    TotalPayment = entity.TotalPayment,
                    TripCity = entity.Trip.City.Name,
                    TripCountry = entity.Trip.City.Country.Name
                };

                _messageService.Publish(message, "trip_service_cancel");
            }

            var purchase = Mapper.Map<Model.Models.Purchase>(entity);

            return new PurchaseCancelResponse
            {
                Purchase = purchase,
                RefundAmount = refundAmount
            };
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

            _messageService.Publish(message, "trip_service_complete");

            return purchase;
        }

        public override void ExpirePurchases()
        {
            var today = DateOnly.FromDateTime(DateTime.UtcNow);

            var purchasesToExpire = Context.Purchases
                .Include(p => p.Trip)
                    .ThenInclude(t => t.City)
                        .ThenInclude(c => c.Country)
                .Include(p => p.User)
                .Where(p => p.Status == "accepted" && p.Trip.DepartureDate <= today)
                .ToList();

            foreach (var purchase in purchasesToExpire)
            {
                purchase.Status = "expired";

                var message = new PurchaseExpired
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

                _messageService.Publish(message, "trip_service_expire");
            }

            Context.SaveChanges();
        }
    }
}
