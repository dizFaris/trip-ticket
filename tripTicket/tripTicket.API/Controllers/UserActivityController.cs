﻿using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Interfaces;

namespace tripTicket.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "Admin")]
    public class UserActivityController : BaseCRUDController<UserActivity, UserActivitySearchObject, UserActivityInsertRequest, UserActivityUpdateRequest>
    {
        public UserActivityController(IUserActivityService service) : base(service)
        {
        }
    }
}
