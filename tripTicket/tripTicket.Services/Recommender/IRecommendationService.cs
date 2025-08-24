using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Models;

namespace tripTicket.Services.Recommender
{
    public interface IRecommendationService
    {
        void TrainModel();
        Task UpdateUserRecommendationsAsync(int userId, int numRecommendations = 5);
    }
}
