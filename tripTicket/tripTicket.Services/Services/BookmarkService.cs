using MapsterMapper;
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
    }
}
