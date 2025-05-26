using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Interfaces;

namespace tripTicket.API.Controllers
{
    public class PurchaseController : BaseCRUDController<Model.Models.Purchase, PurchaseSearchObject, PurchaseInsertRequest, PurchaseUpdateRequest>
    {
        public PurchaseController(IPurchaseService service) : base(service)
        {
        }
    }
}
