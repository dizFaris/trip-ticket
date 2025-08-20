using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;

namespace tripTicket.Services.Interfaces
{
    public interface ISupportTicketService : ICRUDService<SupportTicket, SupportTicketSearchObject, SupportTicketInsertRequest, SupportTicketUpdateRequest>
    {
    }
}
