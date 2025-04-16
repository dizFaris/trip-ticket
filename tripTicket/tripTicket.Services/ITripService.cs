using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;

namespace tripTicket.Services
{
    public interface ITripService
    {
        List<Trip> GetList();
    }
}
