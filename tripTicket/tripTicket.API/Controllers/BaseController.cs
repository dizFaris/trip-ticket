using Microsoft.AspNetCore.Mvc;
using tripTicket.Model;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Interfaces;

namespace tripTicket.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BaseController<TModel, TSearch> : ControllerBase where TSearch : BaseSearchObject
    {
        protected IService<TModel, TSearch> _service;
        public BaseController(IService<TModel, TSearch> service)
        {
            _service = service;
        }

        [HttpGet]
        public PagedResult<TModel> GetList([FromQuery] TSearch searchObject)
        {
            return _service.GetPaged(searchObject);
        }

        [HttpGet("{id}")]
        public ActionResult<TModel> GetById(int id)
        {
            var entity = _service.GetById(id);
            if (entity == null)
                return NotFound(new { message = "Requested entity not found." });

            return Ok(entity);
        }
    }
}
