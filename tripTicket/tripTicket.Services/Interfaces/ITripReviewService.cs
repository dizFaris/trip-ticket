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
    public interface ITripReviewService : ICRUDService<TripReview, TripReviewSearchObject, TripReviewInsertRequest, TripReviewUpdateRequest>
    {
        void DeleteReview(int id);
        public double GetAverageRating(int tripId);
    }
}
