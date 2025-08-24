using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using tripTicket.Services.Database;

namespace tripTicket.Services.Recommender
{
    public class RecommendationService : IRecommendationService
    {
        private readonly TripTicketDbContext _context;
        private static MLContext _mlContext = new MLContext();
        private static ITransformer _model = null!;
        private static readonly object _isLocked = new object();
        private const string ModelFilePath = "trip-recommender.zip";

        public RecommendationService(TripTicketDbContext context)
        {
            _context = context;
        }

        public void TrainModel()
        {
            lock (_isLocked)
            {
                if (File.Exists(ModelFilePath))
                {
                    using var stream = new FileStream(ModelFilePath, FileMode.Open, FileAccess.Read, FileShare.Read);
                    _model = _mlContext.Model.Load(stream, out _);
                    return;
                }

                var purchases = _context.Purchases
                    .Select(p => new UserTripInteraction
                    {
                        UserId = (uint)p.UserId,
                        TripId = (uint)p.TripId,
                        Label = 1f
                    })
                    .ToList();

                var trainingData = _mlContext.Data.LoadFromEnumerable(purchases);

                var options = new MatrixFactorizationTrainer.Options
                {
                    MatrixColumnIndexColumnName = nameof(UserTripInteraction.UserId),
                    MatrixRowIndexColumnName = nameof(UserTripInteraction.TripId),
                    LabelColumnName = nameof(UserTripInteraction.Label),
                    LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                    Alpha = 0.01f,
                    Lambda = 0.025f,
                    NumberOfIterations = 100,
                    ApproximationRank = 50
                };

                var est = _mlContext.Recommendation().Trainers.MatrixFactorization(options);
                _model = est.Fit(trainingData);

                using var saveStream = new FileStream(ModelFilePath, FileMode.Create, FileAccess.Write, FileShare.Write);
                _mlContext.Model.Save(_model, trainingData.Schema, saveStream);
            }
        }

        public async Task UpdateUserRecommendationsAsync(int userId, int numRecommendations = 5)
        {
            if (_model == null)
                TrainModel();

            var predictionEngine = _mlContext.Model.CreatePredictionEngine<UserTripInteraction, RecommendationPrediction>(_model);

            var allTrips = _context.Trips.Where(t => t.TripStatus == "upcoming").ToList();
            var purchasedTripIds = _context.Purchases.Where(p => p.UserId == userId).Select(p => p.TripId).ToHashSet();

            var scoredTrips = allTrips
                .Where(t => !purchasedTripIds.Contains(t.Id))
                .Select(t => new
                {
                    Trip = t,
                    Score = predictionEngine.Predict(new UserTripInteraction
                    {
                        UserId = (uint)userId,
                        TripId = (uint)t.Id
                    }).Score
                })
                .OrderByDescending(x => x.Score)
                .Take(numRecommendations)
                .ToList();

            var oldRecs = _context.UserRecommendations.Where(r => r.UserId == userId);
            _context.UserRecommendations.RemoveRange(oldRecs);

            var newRecs = scoredTrips.Select(s => new UserRecommendation
            {
                UserId = userId,
                TripId = s.Trip.Id,
                Score = (decimal)s.Score,
                CreatedAt = DateTime.UtcNow
            });

            await _context.UserRecommendations.AddRangeAsync(newRecs);
            await _context.SaveChangesAsync();
        }
    }

    public class RecommendationPrediction
    {
        public float Score { get; set; }
    }

    public class UserTripInteraction
    {
        [KeyType(count: 10000)]
        public uint UserId { get; set; }

        [KeyType(count: 10000)]
        public uint TripId { get; set; }

        public float Label { get; set; }
    }
}
