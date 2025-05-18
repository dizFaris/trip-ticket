using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
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
