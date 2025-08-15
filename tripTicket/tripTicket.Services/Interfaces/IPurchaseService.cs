using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.Response;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Services;

namespace tripTicket.Services.Interfaces
{
    public interface IPurchaseService : ICRUDService<Purchase, PurchaseSearchObject, PurchaseInsertRequest, PurchaseUpdateRequest>
    {
        public Purchase FinalizePurchase(int id, bool paymentSucceeded);
        Task<PurchaseCancelResponse> CancelAsync(int id);
        public Purchase Complete(int id);
        Task<byte[]> GenerateTicketPdfAsync(int id);
    }
}
