using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;
using tripTicket.Model.Requests;
using tripTicket.Model.Response;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Database;
using tripTicket.Services.Interfaces;

namespace tripTicket.Services.Services
{
    public class CityService : BaseCRUDService<Model.Models.City, CitySearchObject, Database.City, CityInsertRequest, CityUpdateRequest>, ICityService
    {
        public CityService(TripTicketDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override void BeforeInsert(CityInsertRequest request, City entity)
        {
            if (request.CountryId <= 0)
            {
                throw new UserException("CountryId cannot be null or invalid.");
            }

            var countryExists = Context.Countries.Any(c => c.Id == request.CountryId);

            if (!countryExists)
            {
                throw new UserException($"Country with Id {request.CountryId} does not exist.");
            }

            base.BeforeInsert(request, entity);
        }

        public override Model.Models.City Insert(CityInsertRequest request)
        {
            var existing = Context.Cities
                .FirstOrDefault(c =>
                    c.Name.ToLower() == request.Name.ToLower() &&
                    c.CountryId == request.CountryId);

            if (existing != null)
            {
                if (!existing.IsActive)
                {
                    existing.IsActive = true;
                    Context.SaveChanges();
                }
                else
                {
                    throw new UserException("City already exists");
                }

                return Mapper.Map<Model.Models.City>(existing);
            }

            return base.Insert(request);
        }

        public override IQueryable<City> AddFilter(CitySearchObject search, IQueryable<City> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            filteredQuery = filteredQuery.Where(c => c.IsActive == true);

            if (!string.IsNullOrWhiteSpace(search?.FTS))
            {
                filteredQuery = filteredQuery.Where(x => x.Name.Contains(search.FTS));
            }

            filteredQuery = filteredQuery.OrderBy(c => c.Name);

            return filteredQuery;
        }

        public override void BeforeUpdate(CityUpdateRequest request, City entity)
        {
            base.BeforeUpdate(request, entity);

            if (entity.IsActive && request.IsActive == false)
            {
                bool isCityInUse = Context.Trips.Any(t => t.CityId == entity.Id || t.DepartureCityId == entity.Id);

                if (isCityInUse)
                {
                    throw new UserException("Cannot deactivate city because it is used in one or more trips.");
                }
            }
        }

        public PagedResult<Model.Models.City> GetCitiesByCountryId(int id, CitySearchObject search)
        {
            var query = Context.Set<City>().AsQueryable();

            query = AddFilter(search, query);

            query = query.Where(c => c.CountryId == id);

            int count = query.Count();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip(search.Page.Value * search.PageSize.Value)
                             .Take(search.PageSize.Value);
            }

            var list = query.ToList();
            var result = Mapper.Map<List<Model.Models.City>>(list);

            return new PagedResult<Model.Models.City>
            {
                ResultList = result,
                Count = count
            };
        }
    }
}
