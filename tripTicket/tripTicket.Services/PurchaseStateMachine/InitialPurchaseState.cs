using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;
using tripTicket.Model.Requests;
using tripTicket.Services.Database;

namespace tripTicket.Services.PurchaseStateMachine
{
    public class InitialPurchaseState : BasePurchaseState
    {
        public InitialPurchaseState(TripTicketDbContext context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override Model.Models.Purchase Insert(PurchaseInsertRequest request)
        {
            var trip = Context.Trips.Find(request.TripId);
            var user = Context.Users.Find(request.UserId);

            if (trip == null)
                throw new UserException("Trip not found.");

            if (user == null)
                throw new UserException("User not found");

            if (request.NumberOfTickets <= 0)
                throw new UserException("Number of tickets must be greater than 0.");

            if (request.NumberOfTickets > (trip.AvailableTickets - trip.PurchasedTickets))
                throw new UserException("Not enough tickets available for this trip.");

            decimal ticketPrice = trip.TicketPrice;
            decimal total;

            if (trip.MinTicketsForDiscount.HasValue &&
                trip.DiscountPercentage.HasValue &&
                request.NumberOfTickets >= trip.MinTicketsForDiscount.Value)
            {
                var discountMultiplier = (100 - trip.DiscountPercentage.Value) / 100m;
                total = request.NumberOfTickets * ticketPrice * discountMultiplier;
            }
            else
            {
                total = request.NumberOfTickets * ticketPrice;
            }

            if (Math.Round(request.TotalPayment, 2) != Math.Round(total, 2))
                throw new UserException($"Invalid total payment. Expected: {total:F2}");

            trip.PurchasedTickets += request.NumberOfTickets;

            var set = Context.Set<Purchase>();
            var entity = Mapper.Map<Purchase>(request);
            entity.Status = "accepted";
            entity.CreatedAt = DateTime.Now;
            set.Add(entity);
            Context.SaveChanges();

            return Mapper.Map<Model.Models.Purchase>(entity);
        }
    }
}
