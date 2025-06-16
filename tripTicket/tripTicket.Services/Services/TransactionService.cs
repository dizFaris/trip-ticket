using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Database;
using tripTicket.Services.Interfaces;

namespace tripTicket.Services.Services
{
    public class TransactionService : BaseCRUDService<Model.Models.Transaction, TransactionSearchObject, Database.Transaction, TransactionInsertRequest, TransactionUpdateRequest>, ITransactionService
    {
        public TransactionService(TripTicketDbContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
