using Microsoft.AspNetCore.Mvc;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Interfaces;

namespace tripTicket.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class TripController : BaseCRUDController<Trip, TripSearchObject, TripInsertRequest, TripUpdateRequest>
    {
        protected new ITripService _service;
        public TripController(ITripService service) : base(service)
        {
            _service = service;
        }

        [HttpPut("{id}/cancel")]
        public IActionResult Cancel(int id)
        {
            _service.Cancel(id);
            return Ok();
        }
    }
}
