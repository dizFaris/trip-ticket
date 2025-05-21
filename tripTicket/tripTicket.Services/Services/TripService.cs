using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.SearchObjects;
using tripTicket.Model.Models;
using tripTicket.Services.Database;
using tripTicket.Services.Interfaces;
using tripTicket.Model.Requests;
using tripTicket.Model;
using Microsoft.EntityFrameworkCore;
using tripTicket.Services.TripStateMachine;

namespace tripTicket.Services.Services
    {
        public class TripService : BaseCRUDService<Model.Models.Trip, TripSearchObject, Database.Trip, TripInsertRequest, TripUpdateRequest>, ITripService
        {
            public BaseTripState BaseTripState { get; set; }
            public TripService(TripTicketDbContext context, IMapper mapper, BaseTripState baseTripState) : base(context, mapper)
            {
                BaseTripState = baseTripState;
            }

            public virtual Model.Models.Trip GetById(int id)
            {
                var entity = Context.Set<Database.Trip>().Include(t => t.TripDays).ThenInclude(td => td.TripDayItems).FirstOrDefault(t => t.Id == id);

                if (entity == null)
                {
                    throw new UserException("Trip not found");
                }

                return Mapper.Map<Model.Models.Trip>(entity);
            }

            public override IQueryable<Database.Trip> AddFilter(TripSearchObject search, IQueryable<Database.Trip> query)
            {
                var filteredQuery = base.AddFilter(search, query);

                if (!string.IsNullOrWhiteSpace(search?.FTS))
                {
                    filteredQuery = filteredQuery.Where(x => x.City.Contains(search.FTS) || x.Country.Contains(search.FTS));
                }

                if (search.Year.HasValue)
                {
                    filteredQuery = filteredQuery.Where(x => x.DepartureDate.Year == search.Year.Value);
                }

                if (search.Month.HasValue)
                {
                    filteredQuery = filteredQuery.Where(x => x.DepartureDate.Month == search.Month.Value);
                }

                if (search.Day.HasValue)
                {
                    filteredQuery = filteredQuery.Where(x => x.DepartureDate.Day == search.Day.Value);
                }

                return filteredQuery;
            }

            public override Model.Models.Trip Insert(TripInsertRequest request)
            {
                var state = BaseTripState.CreateState("initial");
                return state.Insert(request);
            }

            public override void BeforeUpdate(TripUpdateRequest request, Database.Trip entity)
            {
                var tripDays = Context.TripDays
                        .Where(td => td.TripId == entity.Id)
                        .ToList();

                foreach (var tripDay in tripDays)
                {
                    var tripDayItems = Context.TripDayItems
                        .Where(tdi => tdi.TripDayId == tripDay.Id)
                        .ToList();

                    Context.TripDayItems.RemoveRange(tripDayItems);
                }

                Context.TripDays.RemoveRange(tripDays);

                Context.SaveChanges();
            }

            public Model.Models.Trip Cancel(int id)
            {
                var entity = GetById(id);

                if (entity == null)
                {
                   throw new UserException("Trip not found.");
                }

                var state = BaseTripState.CreateState(entity.TripStatus);
                return state.Cancel(id);
            }
    }
}
