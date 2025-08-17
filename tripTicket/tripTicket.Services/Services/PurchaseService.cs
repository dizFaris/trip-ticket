using Mapster;
using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;
using tripTicket.Model.Requests;
using tripTicket.Model.Response;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Database;
using tripTicket.Services.Helpers;
using tripTicket.Services.Interfaces;
using tripTicket.Services.PurchaseStateMachine;
using tripTicket.Services.TripStateMachine;

namespace tripTicket.Services.Services
{
    public class PurchaseService : BaseCRUDService<Model.Models.Purchase, PurchaseSearchObject, Database.Purchase, PurchaseInsertRequest, PurchaseUpdateRequest>, IPurchaseService
    {
        public BasePurchaseState BasePurchaseState { get; set; }
        private readonly IHttpContextAccessor _httpContextAccessor;
        public PurchaseService(TripTicketDbContext context, IMapper mapper, BasePurchaseState basePurchaseState, IHttpContextAccessor httpContextAccessor) : base(context, mapper)
        {
            BasePurchaseState = basePurchaseState;
            _httpContextAccessor = httpContextAccessor;
        }

        public override Model.Models.Purchase Insert(PurchaseInsertRequest request)
        {
            var state = BasePurchaseState.CreateState("initial");
            return state.Insert(request);
        }

        public async Task<PurchaseCancelResponse> CancelAsync(int id)
        {
            var entity = GetById(id);

            if (entity == null)
                throw new UserException("Purchase not found.");

            var user = _httpContextAccessor.HttpContext.User;

            var isAdmin = user.IsInRole("Admin");

            var username = user.FindFirstValue(ClaimTypes.NameIdentifier);

            if (!isAdmin && entity.User.Username != username)
            {
                throw new UserException("You are not allowed to cancel this purchase.");
            }

            var state = BasePurchaseState.CreateState(entity.Status);
            return await state.Cancel(id);
        }

        public override IQueryable<Purchase> AddFilter(PurchaseSearchObject search, IQueryable<Purchase> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(p => p.Id.ToString().Contains(search.FTS));
            }

            if (search.FromDate.HasValue)
            {
                query = query.Where(p => p.CreatedAt.Date >= search.FromDate.Value.Date);
            }

            if (search.ToDate.HasValue)
            {
                query = query.Where(p => p.CreatedAt.Date <= search.ToDate.Value.Date);
            }

            if (search.MinTicketCount.HasValue)
                query = query.Where(p => p.NumberOfTickets >= search.MinTicketCount.Value);

            if (search.MaxTicketCount.HasValue)
                query = query.Where(p => p.NumberOfTickets <= search.MaxTicketCount.Value);

            if (search.MinPayment.HasValue)
                query = query.Where(p => p.TotalPayment >= search.MinPayment.Value);

            if (search.MaxPayment.HasValue)
                query = query.Where(p => p.TotalPayment <= search.MaxPayment.Value);

            if (search.UserId.HasValue)
                query = query.Where(p => p.UserId == search.UserId.Value);

            if (!string.IsNullOrWhiteSpace(search.Status))
            {
                query = query.Where(x => x.Status == search.Status);
            }

            query = query.OrderByDescending(p => p.CreatedAt);

            return query;
        }

        public override Model.Models.Purchase Update(int id, PurchaseUpdateRequest request)
        {
            throw new UserException("Method not allowed");
        }

        public override void BeforeUpdate(PurchaseUpdateRequest request, Purchase entity)
        {
            throw new UserException("Method not allowed");
        }

        public override PagedResult<Model.Models.Purchase> GetPaged(PurchaseSearchObject search)
        {
            List<Model.Models.Purchase> result = new List<Model.Models.Purchase>();

            var query = Context.Set<Database.Purchase>()
                .Include(t => t.User)
                .Include(t => t.Trip)
                    .ThenInclude(t => t.City)
                        .ThenInclude(t => t.Country)
                .AsQueryable();

            query = AddFilter(search, query);

            int count = query.Count();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = query.ToList();

            result = Mapper.Map(list, result);

            PagedResult<Model.Models.Purchase> pagedResult = new PagedResult<Model.Models.Purchase>();
            pagedResult.ResultList = result;
            pagedResult.Count = count;

            return pagedResult;
        }

        public override Model.Models.Purchase GetById(int id)
        {
            var entity = Context.Set<Database.Purchase>()
                .Include(p => p.User)
                .Include(p => p.Trip)
                    .ThenInclude(t => t.City)
                        .ThenInclude(c => c.Country)
                .FirstOrDefault(p => p.Id == id);

            if (entity == null)
            {
                throw new UserException("Entity not found");
            }

            return Mapper.Map<Model.Models.Purchase>(entity);
        }

        public Model.Models.Purchase Complete(int id)
        {
            var entity = GetById(id);

            if (entity == null)
            {
                throw new UserException("Purchase not found.");
            }

            var state = BasePurchaseState.CreateState(entity.Status);
            return state.Complete(id);
        }

        public async Task<byte[]> GenerateTicketPdfAsync(int purchaseId)
        {
            var entity = await Context.Purchases
                .Include(x => x.Trip)
                    .ThenInclude(x => x.City)
                        .ThenInclude(x => x.Country)
                .Include(x => x.User)
                .FirstOrDefaultAsync(x => x.Id == purchaseId);

            if (entity == null)
                throw new UserException("Purchase not found.");

            if (entity.IsPrinted)
                throw new UserException("Tickets have already been printed for this purchase.");

            var model = entity.Adapt<Model.Models.Purchase>();

            entity.IsPrinted = true;
            await Context.SaveChangesAsync();

            return TicketPdfGenerator.GenerateTickets(model);
        }

        public Model.Models.Purchase FinalizePurchase(int id, bool paymentSucceeded)
        {
            var entity = Context.Purchases
                .Include(p => p.Trip)
                .FirstOrDefault(p => p.Id == id);

            if (entity == null)
                throw new UserException("Purchase not found.");

            var state = BasePurchaseState.CreateState(entity.Status);
            return state.FinalizePurchase(id, paymentSucceeded);
        }
    }
}
