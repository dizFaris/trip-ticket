using Microsoft.AspNetCore.Mvc;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Interfaces;

namespace tripTicket.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SupportTicketController : BaseCRUDController<SupportTicket, SupportTicketSearchObject, SupportTicketInsertRequest, SupportTicketUpdateRequest>
    {
        public SupportTicketController(ISupportTicketService service) : base(service)
        {
        }
    }
}
