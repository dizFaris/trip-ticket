using Microsoft.AspNetCore.Mvc;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Interfaces;
using tripTicket.Services.Services;

namespace tripTicket.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class TripReviewController : BaseCRUDController<TripReview, TripReviewSearchObject, TripReviewInsertRequest, TripReviewUpdateRequest>
    {
        protected new ITripReviewService _service;
        public TripReviewController(ITripReviewService service) : base(service)
        {
            _service = service;
        }

        [HttpGet("average/{tripId}")]
        public ActionResult<double> GetAverageRating(int tripId)
        {
            var avgRating = _service.GetAverageRating(tripId);
            return Ok(avgRating);
        }

        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            _service.DeleteReview(id);
            return NoContent();
        }
    }
}
