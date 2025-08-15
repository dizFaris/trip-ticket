using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stripe;
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

namespace tripTicket.Services.Services
{
    public class TransactionService : BaseCRUDService<Model.Models.Transaction, TransactionSearchObject, Database.Transaction, TransactionInsertRequest, TransactionUpdateRequest>, ITransactionService
    {
        private readonly string _secretKey;
        private string? secretKey;

        public TransactionService(string secretKey, TripTicketDbContext context, IMapper mapper) : base(context, mapper)
        {
            _secretKey = secretKey;
            StripeConfiguration.ApiKey = _secretKey;
        }

        public PaymentIntent CreatePaymentIntent(int purchaseId)
        {
            var purchase = Context.Purchases.FirstOrDefault(p => p.Id == purchaseId);
            if (purchase == null) throw new UserException("Purchase not found.");

            long amountInCents = (long)(purchase.TotalPayment * 100);

            var options = new PaymentIntentCreateOptions
            {
                Amount = amountInCents,
                Currency = "eur",
                PaymentMethodTypes = new List<string> { "card" }
            };

            var service = new PaymentIntentService();
            var intent = service.Create(options);

            return intent;
        }

        public async Task<Refund> RefundTransactionAsync(string paymentIntentId, decimal amount)
        {
            var service = new RefundService();

            var refundOptions = new RefundCreateOptions
            {
                PaymentIntent = paymentIntentId,
                Amount = (long)(amount * 100)
            };

            return await service.CreateAsync(refundOptions);
        }
    }
}
