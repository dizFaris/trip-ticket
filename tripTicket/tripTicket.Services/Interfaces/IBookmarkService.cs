using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;

namespace tripTicket.Services.Interfaces
{
    public interface IBookmarkService : ICRUDService<Bookmark, BookmarkSearchObject, BookmarkInsertRequest, BookmarkUpdateRequest>
    {
        object DeleteBookmark(int userId, int tripId);
        PagedResult<Bookmark> GetBoomarksByUserId(int userId);
        bool IsTripBookmarked(int userId, int tripId);
    }
}
