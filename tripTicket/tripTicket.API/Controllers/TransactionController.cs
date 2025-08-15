using Microsoft.AspNetCore.Mvc;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Interfaces;
using tripTicket.Services.Services;

namespace tripTicket.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class TransactionController : BaseCRUDController<Transaction, TransactionSearchObject, TransactionInsertRequest, TransactionUpdateRequest>
    {
        private readonly ITransactionService _transactionService;
        public TransactionController(ITransactionService service) : base(service)
        {
            _transactionService = service;
        }

        public override Transaction Update(int id, TransactionUpdateRequest request)
        {
            throw new NotImplementedException("Direct transaction update is not allowed");
        }

        [HttpPost("create-payment-intent")]
        public ActionResult CreatePaymentIntent([FromBody] TransactionPaymentIntentRequest request)
        {
            if (request == null || request.PurchaseId <= 0)
                return BadRequest("Invalid purchase ID.");

            var intent = _transactionService.CreatePaymentIntent(request.PurchaseId);

            return Ok(new
            {
                clientSecret = intent.ClientSecret,
                stripeTransactionId = intent.Id
            });
        }
    }
}
