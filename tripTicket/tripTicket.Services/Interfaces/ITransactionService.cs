using Stripe;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;

namespace tripTicket.Services.Interfaces
{
    public interface ITransactionService : ICRUDService<Transaction, TransactionSearchObject, TransactionInsertRequest, TransactionUpdateRequest>
    {
        PaymentIntent CreatePaymentIntent(int purchaseId);
        Task<Refund> RefundTransactionAsync(string paymentIntentId, decimal amount);
    }
}
