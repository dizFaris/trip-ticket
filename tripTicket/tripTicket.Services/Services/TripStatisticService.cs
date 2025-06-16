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
    public class TripStatisticService : BaseCRUDService<Model.Models.TripStatistic, TripStatisticSearchObject, Database.TripStatistic, TripStatisticInsertRequest, TripStatisticUpdateRequest>, ITripStatisticService
    {
        public TripStatisticService(TripTicketDbContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
