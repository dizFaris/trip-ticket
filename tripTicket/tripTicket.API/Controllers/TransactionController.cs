using Microsoft.AspNetCore.Mvc;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Interfaces;

namespace tripTicket.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class TransactionController : BaseCRUDController<Transaction, TransactionSearchObject, TransactionInsertRequest, TransactionUpdateRequest>
    {
        public TransactionController(ITransactionService service) : base(service)
        {
        }
    }
}
