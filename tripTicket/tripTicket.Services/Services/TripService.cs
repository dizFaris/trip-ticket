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
using Mapster;

namespace tripTicket.Services.Services
{
    public class TripService : BaseCRUDService<Model.Models.Trip, TripSearchObject, Database.Trip, TripInsertRequest, TripUpdateRequest>, ITripService
    {
        public BaseTripState BaseTripState { get; set; }
        public TripService(TripTicketDbContext context, IMapper mapper, BaseTripState baseTripState) : base(context, mapper)
        {
            BaseTripState = baseTripState;
        }

        public override PagedResult<Model.Models.Trip> GetPaged(TripSearchObject search)
        {
            List<Model.Models.Trip> result = new List<Model.Models.Trip>();

            var query = Context.Set<Database.Trip>()
                .Include(t => t.City)
                    .ThenInclude(td => td.Country)
                .Include(t => t.DepartureCity)
                    .ThenInclude(td => td.Country)
                .AsQueryable();

            query = AddFilter(search, query);

            int count = query.Count();

            int page = (search?.Page.HasValue == true && search.Page.Value >= 0) ? search.Page.Value : 0;
            int pageSize = (search?.PageSize.HasValue == true && search.PageSize.Value > 0) ? search.PageSize.Value : 10;

            query = query.Skip(page * pageSize).Take(pageSize);

            var list = query.ToList();

            result = Mapper.Map(list, result);

            PagedResult<Model.Models.Trip> pagedResult = new PagedResult<Model.Models.Trip>();
            pagedResult.ResultList = result;
            pagedResult.Count = count;

            return pagedResult;
        }

        public override Model.Models.Trip GetById(int id)
        {
            var entity = Context.Set<Database.Trip>()
                .Include(t => t.City)
                    .ThenInclude(td => td.Country)
                .Include(t => t.DepartureCity)
                    .ThenInclude(td => td.Country)
                .Include(t => t.TripDays)
                    .ThenInclude(td => td.TripDayItems)
                .FirstOrDefault(t => t.Id == id);

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
                filteredQuery = filteredQuery.Where(x => x.City.Name.Contains(search.FTS) || x.City.Country.Name.Contains(search.FTS));
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

            if (!string.IsNullOrWhiteSpace(search.Status))
            {
                filteredQuery = filteredQuery.Where(x => x.TripStatus == search.Status);
            }

            if (search.FromDate.HasValue)
            {
                filteredQuery = filteredQuery.Where(p => p.DepartureDate >= search.FromDate.Value);
            }

            if (search.ToDate.HasValue)
            {
                filteredQuery = filteredQuery.Where(p => p.DepartureDate <= search.ToDate.Value);
            }

            filteredQuery = filteredQuery.OrderByDescending(p => p.CreatedAt);

            return filteredQuery;
        }

        public override Model.Models.Trip Insert(TripInsertRequest request)
        {
            var state = BaseTripState.CreateState("initial");
            return state.Insert(request);
        }

        public override Model.Models.Trip Update(int id, TripUpdateRequest request)
        {
            var set = Context.Set<Database.Trip>();

            var entity = set.SingleOrDefault(t => t.Id == id);

            if (entity == null)
            {
                throw new Exception($"Trip with id {id} not found.");
            }

            Mapper.Map(request, entity);

            BeforeUpdate(request, entity);

            Context.SaveChanges();

            entity = set
                .Include(t => t.City)
                    .ThenInclude(c => c.Country)
                .Include(t => t.DepartureCity)
                    .ThenInclude(dc => dc.Country)
                .SingleOrDefault(t => t.Id == id);

            return Mapper.Map<Model.Models.Trip>(entity);
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

        public virtual List<Model.Models.Trip> GetRecommendedTrips(int userId)
        {
            var recommendedTripIds = Context.UserRecommendations
                .Where(r => r.UserId == userId)
                .OrderByDescending(r => r.Score)
                .Select(r => r.TripId)
                .ToList();

            var trips = Context.Trips
                .Include(t => t.City)
                    .ThenInclude(c => c.Country)
                .Include(t => t.DepartureCity)
                    .ThenInclude(c => c.Country)
                .Where(t => recommendedTripIds.Contains(t.Id))
                .ToList();

            var mappedTrips = trips.Adapt<List<Model.Models.Trip>>();

            mappedTrips = mappedTrips
                .OrderBy(t => recommendedTripIds.IndexOf(t.Id))
                .ToList();

            return mappedTrips;
        }
    }
}
