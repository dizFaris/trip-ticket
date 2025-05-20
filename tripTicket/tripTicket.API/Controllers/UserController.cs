using Microsoft.AspNetCore.Mvc;
using tripTicket.Model;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Interfaces;

namespace tripTicket.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : BaseCRUDController<User, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        protected new IUserService _service;
        public UserController(IUserService service) : base(service)
        {
            _service = service;
        }
    }
}
