using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;
using tripTicket.Model.Requests;
using tripTicket.Services.Database;

namespace tripTicket.Services.TripStateMachine
{
    public class InitialTripState : BaseTripState
    {
        public InitialTripState(TripTicketDbContext context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override Model.Models.Trip Insert(TripInsertRequest request)
        {
            var city = Context.Cities
                .Include(c => c.Country)
                .FirstOrDefault(c => c.Id == request.CityId);

            if (city == null)
                throw new UserException("The selected city does not exist.");

            var departureCity = Context.Cities.
                Include(c => c.Country)
                .FirstOrDefault(c => c.Id == request.DepartureCityId);

            if (departureCity == null)
                throw new UserException("The selected departure city does not exist.");

            if (request.Photo != null && request.Photo.Length > 50_000)
                throw new UserException("Photo must be smaller than 50KB.");

            if (request.DepartureDate < DateOnly.FromDateTime(DateTime.Today.AddDays(5)))
                throw new UserException("Departure date must be at least 5 days from today.");

            if (request.ReturnDate < request.DepartureDate)
                throw new UserException("Return date cannot be before the departure date.");

            if (request.TicketPrice <= 0)
                throw new UserException("Ticket price must be greater than 0.");

            if (request.AvailableTickets <= 0)
                throw new UserException("At least one available ticket is required.");

            if (request.FreeCancellationUntil != null && request.FreeCancellationUntil >= request.DepartureDate.AddDays(-2))
            {
                throw new UserException("Free cancellation must be at least 3 days before the departure date.");
            }

            var set = Context.Set<Trip>();
            var entity = Mapper.Map<Trip>(request);
            entity.TripStatus = "upcoming";
            entity.CreatedAt = DateTime.Now;
            entity.TicketSaleEnd = request.DepartureDate.ToDateTime(TimeOnly.MinValue).AddDays(-3);
            set.Add(entity);
            Context.SaveChanges();

            return Mapper.Map<Model.Models.Trip>(entity);
        }
    }
}
