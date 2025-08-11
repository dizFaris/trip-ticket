using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Database;
using tripTicket.Services.Interfaces;

namespace tripTicket.Services.Services
{
    public class BookmarkService : BaseCRUDService<Model.Models.Bookmark, BookmarkSearchObject, Database.Bookmark, BookmarkInsertRequest, BookmarkUpdateRequest>, IBookmarkService
    {
        public BookmarkService(TripTicketDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override void BeforeInsert(BookmarkInsertRequest request, Bookmark entity)
        {
            var trip = Context.Set<Trip>().Find(request.TripId);
            if (trip == null)
            {
                throw new UserException("Trip not found");
            }

            var user = Context.Set<User>().Find(request.UserId);
            if (user == null)
            {
                throw new UserException("User not found");
            }

            bool bookmarkExists = Context.Set<Bookmark>()
                .Any(b => b.UserId == request.UserId && b.TripId == request.TripId);

            if (bookmarkExists)
            {
                throw new UserException("Bookmark already exists for this trip and user.");
            }
        }

        public object DeleteBookmark(int userId, int tripId)
        {
            var bookmark = Context.Bookmarks
                .FirstOrDefault(b => b.UserId == userId && b.TripId == tripId);

            if (bookmark == null)
            {
                throw new UserException("Bookmark not found.");
            }

            Context.Bookmarks.Remove(bookmark);
            Context.SaveChanges();

            return true;
        }

        public override PagedResult<Model.Models.Bookmark> GetPaged(BookmarkSearchObject search)
        {
            List<Model.Models.Bookmark> result = new List<Model.Models.Bookmark>();

            var query = Context.Set<Database.Bookmark>()
                .Include(b => b.Trip)
                    .ThenInclude(t => t.City)
                        .ThenInclude(c => c.Country)
                .Include(b => b.Trip)
                    .ThenInclude(t => t.DepartureCity)
                        .ThenInclude(dc => dc.Country)
                .AsQueryable();

            query = AddFilter(search, query);

            int count = query.Count();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = query.ToList();

            result = Mapper.Map(list, result);

            PagedResult<Model.Models.Bookmark> pagedResult = new PagedResult<Model.Models.Bookmark>();
            pagedResult.ResultList = result;
            pagedResult.Count = count;

            return pagedResult;
        }

        public override IQueryable<Bookmark> AddFilter(BookmarkSearchObject search, IQueryable<Bookmark> query)
        {
            query = base.AddFilter(search, query);

            if (search.UserId.HasValue)
                query = query.Where(p => p.UserId == search.UserId.Value);

            return query;
        }

        public bool IsTripBookmarked(int userId, int tripId)
        {
            var userExists = Context.Users.Any(u => u.Id == userId);
            if (!userExists)
            {
                throw new UserException("User not found.");
            }

            var tripExists = Context.Trips.Any(t => t.Id == tripId);
            if (!tripExists)
            {
                throw new UserException("Trip not found.");
            }

            return Context.Bookmarks.Any(b => b.UserId == userId && b.TripId == tripId);
        }

        public override Model.Models.Bookmark Insert(BookmarkInsertRequest request)
        {
            Database.Bookmark entity = Mapper.Map<Database.Bookmark>(request);

            BeforeInsert(request, entity);

            Context.Add(entity);
            Context.SaveChanges();

            var loadedEntity = Context.Set<Database.Bookmark>()
                .Include("Trip")
                .Include("Trip.City")
                .Include("Trip.City.Country")
                .Include("Trip.DepartureCity")
                .Include("Trip.DepartureCity.Country")
                .FirstOrDefault(e => e.Id == entity.Id);

            return Mapper.Map<Model.Models.Bookmark>(loadedEntity);
        }
    }
}
