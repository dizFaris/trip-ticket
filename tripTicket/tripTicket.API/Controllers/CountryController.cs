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
    public class CountryController : BaseCRUDController<Country, CountrySearchObject, CountryInsertRequest, CountryUpdateRequest>
    {
        protected new ICountryService _service;
        public CountryController(ICountryService service) : base(service)
        {
            _service = service;
        }
    }
}
