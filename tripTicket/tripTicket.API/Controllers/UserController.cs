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
        public IActionResult Login([FromBody] LoginRequest request)
        {
            var user = (_service as IUserService).Login(request.username, request.password);

            var clientTypeRaw = Request.Headers["X-Client-Type"].ToString();
            var clientType = clientTypeRaw?.Trim().ToLower();

            if (string.IsNullOrEmpty(clientType) || (clientType != "desktop" && clientType != "mobile"))
            {
                return BadRequest(new { error = "Invalid or missing 'X-Client-Type' header. Must be 'desktop' or 'mobile'." });
            }

            if (clientType == "desktop" && !user.Roles.Contains("Admin"))
            {
                return Unauthorized(new { error = "Only admins can log in from the desktop app." });
            }

            if (clientType == "mobile" && user.Roles.Contains("Admin"))
            {
                return Unauthorized(new { error = "Admins cannot log in from the mobile app." });
            }

            return Ok(user);
        }
    }
}
