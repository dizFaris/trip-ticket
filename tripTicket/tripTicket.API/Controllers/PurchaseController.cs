using Microsoft.AspNetCore.Mvc;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.Response;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Interfaces;
using tripTicket.Services.Services;

namespace tripTicket.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PurchaseController : BaseCRUDController<Model.Models.Purchase, PurchaseSearchObject, PurchaseInsertRequest, PurchaseUpdateRequest>
    {
        protected new IPurchaseService _service;

        public PurchaseController(IPurchaseService service) : base(service)
        {
            _service = service;
        }

        [HttpPut("{id}/cancel")]
        public async Task<PurchaseCancelResponse> CancelAsync(int id)
        {
            return await _service.CancelAsync(id);
        }

        [HttpPut("{id}/complete")]
        public Purchase Complete(int id)
        {
            return _service.Complete(id);
        }

        [HttpPut("{id}/finalize")]
        public async Task<Purchase> Finalize(int id, [FromBody] PurchaseUpdateRequest request)
        {
            return await _service.FinalizePurchase(id, request.PaymentSucceeded);
        }

        [HttpGet("{id}/ticket-pdf")]
        public async Task<IActionResult> GetYearlyEarningsPdf(int id)
        {
            var pdfBytes = await _service.GenerateTicketPdfAsync(id);
            var fileName = $"Purchase-{id}.pdf";
            return File(pdfBytes, "application/pdf", fileName);
        }
    }
}
