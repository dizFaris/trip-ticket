using Microsoft.AspNetCore.Mvc;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Interfaces;

namespace tripTicket.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BookmarkController : BaseCRUDController<Bookmark, BookmarkSearchObject, BookmarkInsertRequest, BookmarkUpdateRequest>
    {
        public BookmarkController(IBookmarkService service) : base(service)
        {
        }
    }
}
