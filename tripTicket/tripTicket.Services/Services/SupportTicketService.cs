using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Database;
using tripTicket.Services.Interfaces;

namespace tripTicket.Services.Services
{
    public class SupportTicketService : BaseCRUDService<Model.Models.SupportTicket, SupportTicketSearchObject, Database.SupportTicket, SupportTicketInsertRequest, SupportTicketUpdateRequest>, ISupportTicketService
    {
        public SupportTicketService(TripTicketDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override void BeforeInsert(SupportTicketInsertRequest request, Database.SupportTicket entity)
        {
            if (string.IsNullOrWhiteSpace(request.Subject))
                throw new UserException("Subject is required");

            if (string.IsNullOrWhiteSpace(request.Message))
                throw new UserException("Message is required");

            var userExists = Context.Users.Any(u => u.Id == request.UserId);
            if (!userExists)
                throw new UserException($"User with Id {request.UserId} does not exist");

            base.BeforeInsert(request, entity);
        }

        public override PagedResult<Model.Models.SupportTicket> GetPaged(SupportTicketSearchObject search)
        {
            List<Model.Models.SupportTicket> result = new List<Model.Models.SupportTicket>();

            var query = Context.Set<Database.SupportTicket>()
                .Include(s => s.User)
                .AsQueryable();

            query = AddFilter(search, query);

            int count = query.Count();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = query.ToList();

            result = Mapper.Map(list, result);

            PagedResult<Model.Models.SupportTicket> pagedResult = new PagedResult<Model.Models.SupportTicket>();
            pagedResult.ResultList = result;
            pagedResult.Count = count;

            return pagedResult;
        }

        public override IQueryable<Database.SupportTicket> AddFilter(SupportTicketSearchObject search, IQueryable<Database.SupportTicket> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(s => s.User.Username.Contains(search.FTS) || s.Subject.Contains(search.FTS));
            }

            if (search.FromDate.HasValue)
            {
                query = query.Where(s => s.CreatedAt.Date >= search.FromDate.Value.Date);
            }

            if (search.ToDate.HasValue)
            {
                query = query.Where(s => s.CreatedAt.Date <= search.ToDate.Value.Date);
            }

            if (!string.IsNullOrWhiteSpace(search.Status))
            {
                query = query.Where(s => s.Status == search.Status);
            }

            query = query.OrderByDescending(p => p.CreatedAt);

            return query;
        }
    }
}
