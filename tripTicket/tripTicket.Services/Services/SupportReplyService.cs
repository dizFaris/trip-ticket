using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;
using tripTicket.Model.Messages;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Database;
using tripTicket.Services.Interfaces;

namespace tripTicket.Services.Services
{
    public class SupportReplyService : BaseCRUDService<Model.Models.SupportReply, SupportReplySearchObject, Database.SupportReply, SupportReplyInsertRequest, SupportReplyUpdateRequest>, ISupportReplyService
    {
        private readonly IMessageService _messageService;
        public SupportReplyService(TripTicketDbContext context, IMapper mapper, IMessageService messageService) : base(context, mapper)
        {
            _messageService = messageService;
        }

        public override void BeforeInsert(SupportReplyInsertRequest request, SupportReply entity)
        {
            if (string.IsNullOrWhiteSpace(request.Message))
                throw new UserException("Message is required.");

            var ticketExists = Context.SupportTickets.Any(t => t.Id == request.TicketId);
            if (!ticketExists)
                throw new UserException($"Support ticket with Id {request.TicketId} does not exist.");

            base.BeforeInsert(request, entity);
        }

        public override Model.Models.SupportReply Insert(SupportReplyInsertRequest request)
        {
            var reply = base.Insert(request);

            var ticket = Context.Set<SupportTicket>()
                .Include(t => t.User)
                .FirstOrDefault(t => t.Id == request.TicketId);

            if (ticket != null)
            {
                ticket.Status = "resolved";
                ticket.ResolvedAt = DateTime.UtcNow;
                Context.SaveChanges();
            }

            SupportTicketReply message = new SupportTicketReply
            {
                TicketId = request.TicketId,
                Name = ticket.User.FirstName,
                Email = ticket.User.Email,
                Message = request.Message,
                Subject = ticket.Subject,
            };

            _messageService.Publish(message);

            return reply;
        }

        public override PagedResult<Model.Models.SupportReply> GetPaged(SupportReplySearchObject search)
        {
            List<Model.Models.SupportReply> result = new List<Model.Models.SupportReply>();

            var query = Context.Set<Database.SupportReply>()
                .Include(t => t.Ticket)
                    .ThenInclude(t => t.User)
                .AsQueryable();

            query = AddFilter(search, query);

            int count = query.Count();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = query.ToList();

            result = Mapper.Map(list, result);

            PagedResult<Model.Models.SupportReply> pagedResult = new PagedResult<Model.Models.SupportReply>();
            pagedResult.ResultList = result;
            pagedResult.Count = count;

            return pagedResult;
        }

        public override IQueryable<SupportReply> AddFilter(SupportReplySearchObject search, IQueryable<SupportReply> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(s => s.Ticket.Subject.Contains(search.FTS) || s.Ticket.User.Username.Contains(search.FTS));
            }

            if (search.FromDate.HasValue)
            {
                query = query.Where(s => s.CreatedAt.Date >= search.FromDate.Value);
            }

            if (search.ToDate.HasValue)
            {
                query = query.Where(s => s.CreatedAt.Date <= search.ToDate.Value);
            }

            query = query.OrderByDescending(p => p.CreatedAt);

            return query;
        }
    }
}
