using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Database;
using tripTicket.Services.Interfaces;

namespace tripTicket.Services.Services
{
    public class NotificationService : BaseCRUDService<Model.Models.Notification, NotificationSearchObject, Database.Notification, NotificationInsertRequest, NotificationUpdateRequest>, INotificationService
    {
        public NotificationService(TripTicketDbContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
