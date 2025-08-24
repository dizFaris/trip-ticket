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
        private static MLContext _mlContext = null!;
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
                if (_mlContext == null)
                    _mlContext = new MLContext();

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
            var purchasedTrips = _context.Purchases
                .Where(p => p.UserId == userId)
                .Include(p => p.Trip)
                    .ThenInclude(t => t.City)
                    .ThenInclude(c => c.Country)
                .Select(p => p.Trip)
                .ToList();


            var tripFeatures = allTrips.Select(t => new TripFeatureVector
            {
                Trip = t,
                Vector = BuildTripVector(t)
            }).ToList();

            if (!tripFeatures.Any())
                return;

            var userProfileVector = purchasedTrips
                .Select(BuildTripVector)
                .Aggregate(new float[tripFeatures.First().Vector.Length], (acc, vec) =>
                {
                    for (int i = 0; i < vec.Length; i++)
                        acc[i] += vec[i];
                    return acc;
                });

            if (purchasedTrips.Any())
            {
                for (int i = 0; i < userProfileVector.Length; i++)
                    userProfileVector[i] /= purchasedTrips.Count;
            }

            var purchasedTripIds = purchasedTrips.Select(t => t.Id).ToHashSet();

            var scoredTrips = tripFeatures
                .Where(t => !purchasedTripIds.Contains(t.Trip.Id))
                .Select(t => new
                {
                    Trip = t.Trip,
                    ContentScore = CosineSimilarity(userProfileVector, t.Vector),
                    CFScore = predictionEngine.Predict(new UserTripInteraction
                    {
                        UserId = (uint)userId,
                        TripId = (uint)t.Trip.Id
                    }).Score
                })

                .Select(t => new
                {
                    t.Trip,
                    Score = t.ContentScore * 0.7f + t.CFScore * 0.3f
                })
                .OrderByDescending(t => t.Score)
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

        private float[] BuildTripVector(Trip trip)
        {
            var tripTypes = new[] {
                    "Romantic",
                    "Adventure",
                    "Cultural",
                    "Relaxing",
                    "Family",
                    "Luxury",
                    "Eco-tourism",
                    "Road Trip",
                    "Wellness",
                    "Historical",
                    "City Tour",
                    "Safari",
                    "Nature",
                    "Beach",
                    "Vacation"
            };
            float[] vector = new float[tripTypes.Length + 2];

            for (int i = 0; i < tripTypes.Length; i++)
                vector[i] = trip.TripType == tripTypes[i] ? 1f : 0f;

            vector[tripTypes.Length] = (float)trip.TicketPrice / 1000f;

            vector[tripTypes.Length + 1] = (float)(trip.ReturnDate.DayNumber - trip.DepartureDate.DayNumber) / 30f;

            return vector;
        }

        private float CosineSimilarity(float[] v1, float[] v2)
        {
            float dot = 0, normA = 0, normB = 0;
            for (int i = 0; i < v1.Length; i++)
            {
                dot += v1[i] * v2[i];
                normA += v1[i] * v1[i];
                normB += v2[i] * v2[i];
            }
            return dot / ((float)Math.Sqrt(normA) * (float)Math.Sqrt(normB) + 1e-5f);
        }
    }

    public class UserTripInteraction
    {
        [KeyType(count: 10000)]
        public uint UserId { get; set; }

        [KeyType(count: 10000)]
        public uint TripId { get; set; }

        public float Label { get; set; }
    }

    public class RecommendationPrediction
    {
        public float Score { get; set; }
    }

    public class TripFeatureVector
    {
        public Trip Trip { get; set; } = null!;
        public float[] Vector { get; set; } = null!;
    }
}
