using Microsoft.AspNetCore.Mvc;
using tripTicket.Model;
using tripTicket.Services;

namespace tripTicket.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class TripController : Controller
    {
        protected ITripService _tripService;
        public TripController(ITripService service)
        {
            _tripService = service;
        }
        [HttpGet]
        public List<Trip> GetList()
        {
            return _tripService.GetList();
        }
    }
}
