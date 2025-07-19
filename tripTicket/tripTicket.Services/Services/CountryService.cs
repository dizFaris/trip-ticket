using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.Response;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Database;
using tripTicket.Services.Interfaces;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

namespace tripTicket.Services.Services
{
    public class CountryService : BaseCRUDService<Model.Models.Country, CountrySearchObject, Database.Country, CountryInsertRequest, CountryUpdateRequest>, ICountryService
    {
        public CountryService(TripTicketDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override Model.Models.Country Insert(CountryInsertRequest request)
        {
            var existing = Context.Countries
                .FirstOrDefault(c =>
                    c.Name.ToLower() == request.Name.ToLower() ||
                    c.CountryCode.ToLower() == request.CountryCode.ToLower());

            if (existing != null)
            {
                if (!existing.IsActive)
                {
                    existing.IsActive = true;
                    Context.SaveChanges();
                }
                else
                {
                    throw new UserException("Country already exists");
                }

                return Mapper.Map<Model.Models.Country>(existing);
            }

            return base.Insert(request);
        }

        public override IQueryable<Database.Country> AddFilter(CountrySearchObject search, IQueryable<Database.Country> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            filteredQuery = filteredQuery.Where(c => c.IsActive == true);

            if (!string.IsNullOrWhiteSpace(search?.FTS))
            {
                filteredQuery = filteredQuery.Where(x => x.Name.Contains(search.FTS));
            }

            return filteredQuery;
        }

        public override void BeforeUpdate(CountryUpdateRequest request, Database.Country entity)
        {
            base.BeforeUpdate(request, entity);

            if (request.IsActive.HasValue)
            {
                var cities = Context.Cities.Where(c => c.CountryId == entity.Id).ToList();

                foreach (var city in cities)
                {
                    city.IsActive = request.IsActive.Value;
                }

                Context.SaveChanges();
            }
        }
    }
}
