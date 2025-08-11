using Microsoft.AspNetCore.Mvc;
using tripTicket.Model;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Interfaces;
using tripTicket.Services.Services;

namespace tripTicket.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BookmarkController : BaseCRUDController<Bookmark, BookmarkSearchObject, BookmarkInsertRequest, BookmarkUpdateRequest>
    {
        protected new IBookmarkService _service;
        public BookmarkController(IBookmarkService service) : base(service)
        {
            _service = service;
        }

        [HttpDelete("delete")]
        public ActionResult<bool> DeleteBookmark([FromQuery] int userId, [FromQuery] int tripId)
        {
            var result = _service.DeleteBookmark(userId, tripId);
            return Ok(result);
        }

        [HttpGet("is-bookmarked")]
        public ActionResult<bool> IsTripBookmarked([FromQuery] int userId, [FromQuery] int tripId)
        {
            bool isBookmarked = _service.IsTripBookmarked(userId, tripId);
            return Ok(isBookmarked);
        }
    }
}
