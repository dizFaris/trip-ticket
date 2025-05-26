using MapsterMapper;
using Microsoft.EntityFrameworkCore;
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
using tripTicket.Services.PurchaseStateMachine;
using tripTicket.Services.TripStateMachine;

namespace tripTicket.Services.Services
{
    public class PurchaseService : BaseCRUDService<Model.Models.Purchase, PurchaseSearchObject, Database.Purchase, PurchaseInsertRequest, PurchaseUpdateRequest>, IPurchaseService
    {
        public BasePurchaseState BasePurchaseState { get; set; }
        public PurchaseService(TripTicketDbContext context, IMapper mapper, BasePurchaseState basePurchaseState) : base(context, mapper)
        {
            BasePurchaseState = basePurchaseState;
        }

        public override Model.Models.Purchase Insert(PurchaseInsertRequest request)
        {
            var state = BasePurchaseState.CreateState("initial");
            return state.Insert(request);
        }

        public Model.Models.Purchase Cancel(int id)
        {
            var entity = GetById(id);

            if (entity == null)
            {
                throw new UserException("Purchase not found.");
            }

            var state = BasePurchaseState.CreateState(entity.Status);
            return state.Cancel(id);
        }

        public override Model.Models.Purchase Update(int id, PurchaseUpdateRequest request)
        {
            throw new UserException("Method not allowed");
        }

        public override void BeforeUpdate(PurchaseUpdateRequest request, Purchase entity)
        {
            throw new UserException("Method not allowed");
        }
    }
}
