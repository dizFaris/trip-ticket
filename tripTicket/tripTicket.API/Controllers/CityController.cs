using Microsoft.AspNetCore.Mvc;
using tripTicket.Model;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.Response;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Interfaces;

namespace tripTicket.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CityController : BaseCRUDController<City, CitySearchObject, CityInsertRequest, CityUpdateRequest>
    {
        protected new ICityService _service;
        public CityController(ICityService service) : base(service)
        {
            _service = service;
        }

        [HttpGet("country/{id}/cities")]
        public virtual PagedResult<City> GetCitiesByCountryId(int id, [FromQuery] CitySearchObject searchObject)
        {
            return _service.GetCitiesByCountryId(id, searchObject);
        }
    }
}
