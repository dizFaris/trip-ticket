using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Database;
using tripTicket.Services.Interfaces;

namespace tripTicket.Services.Services
{
    public class UserActivityService : BaseCRUDService<Model.Models.UserActivity, UserActivitySearchObject, Database.UserActivity, UserActivityInsertRequest, UserActivityUpdateRequest>, IUserActivityService
    {
        public UserActivityService(TripTicketDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override void BeforeUpdate(UserActivityUpdateRequest request, UserActivity entity)
        {
            throw new UserException("Method not allowed");
        }

        public override Model.Models.UserActivity Update(int id, UserActivityUpdateRequest request)
        {
            throw new UserException("Method not allowed");
        }

        public override void BeforeInsert(UserActivityInsertRequest request, UserActivity entity)
        {
            var user = Context.Set<User>().Find(request.UserId);

            if (user == null)
            {
                throw new UserException($"User with ID {request.UserId} not found.");
            }
        }
    }
}
