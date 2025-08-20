using Microsoft.AspNetCore.Mvc;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Interfaces;

namespace tripTicket.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SupportReplyController : BaseCRUDController<SupportReply, SupportReplySearchObject, SupportReplyInsertRequest, SupportReplyUpdateRequest>
    {
        public SupportReplyController(ISupportReplyService service) : base(service)
        {
        }
    }
}
