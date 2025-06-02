using Microsoft.AspNetCore.Authorization;
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
        public UserController(IUserService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override User Insert(UserInsertRequest request)
        {
            return base.Insert(request);
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public Model.Models.User Login(LoginRequest request)
        {
            return (_service as IUserService).Login(request.username, request.password);
        }
    }
}
