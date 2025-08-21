using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Services.Database;
using tripTicket.Services.Interfaces;

namespace tripTicket.Services.Services
{
    public class RecommendationService : IRecommendationService
    {
        public TripTicketDbContext Context { get; set; }

        public RecommendationService(TripTicketDbContext context)
        {
            Context = context;
        }

        public async Task UpdateUserRecommendationsAsync(int userId)
        {
            var purchasedTrips = await Context.Purchases
                .Where(p => p.UserId == userId)
                .Select(p => p.Trip)
                .ToListAsync();

            if (!purchasedTrips.Any())
                return;

            var allTrips = await Context.Trips
                .Where(t => t.TripStatus == "upcoming")
                .ToListAsync();

            var recommendations = new List<UserRecommendation>();

            foreach (var trip in allTrips)
            {
                if (purchasedTrips.Any(pt => pt.Id == trip.Id)) continue;

                float maxScore = 0f;
                foreach (var purchased in purchasedTrips)
                {
                    float score = ComputeSimilarity(purchased, trip);
                    if (score > maxScore)
                        maxScore = score;
                }

                if (maxScore > 0)
                {
                    recommendations.Add(new UserRecommendation
                    {
                        UserId = userId,
                        TripId = trip.Id,
                        Score = (decimal)maxScore
                    });
                }
            }

            var oldRecs = Context.UserRecommendations.Where(r => r.UserId == userId);
            Context.UserRecommendations.RemoveRange(oldRecs);

            await Context.UserRecommendations.AddRangeAsync(recommendations);
            await Context.SaveChangesAsync();
        }

        private float ComputeSimilarity(Trip a, Trip b)
        {
            // TicketPrice, Duration, TripType
            float[] fA = new float[]
            {
            (float)a.TicketPrice,
            (float)(a.ReturnDate.DayNumber - a.DepartureDate.DayNumber),
            TripTypeToNumber(a.TripType)
            };

            float[] fB = new float[]
            {
            (float)b.TicketPrice,
            (float)(b.ReturnDate.DayNumber - b.DepartureDate.DayNumber),
            TripTypeToNumber(b.TripType)
            };

            return CosineSimilarity(fA, fB);
        }

        private int TripTypeToNumber(string? type)
        {
            return type?.ToLower() switch
            {
                "romantic" => 1,
                "adventure" => 2,
                "cultural" => 3,
                "relaxing" => 4,
                "family" => 5,
                "luxury" => 6,
                "eco-tourism" => 7,
                "road trip" => 8,
                "wellness" => 9,
                "historical" => 10,
                "city tour" => 11,
                "safari" => 12,
                "nature" => 13,
                "beach" => 14,
                "vacation" => 15,
                _ => 0
            };
        }

        private float CosineSimilarity(float[] v1, float[] v2)
        {
            float dot = 0, mag1 = 0, mag2 = 0;
            for (int i = 0; i < v1.Length; i++)
            {
                dot += v1[i] * v2[i];
                mag1 += v1[i] * v1[i];
                mag2 += v2[i] * v2[i];
            }
            return (float)(dot / (Math.Sqrt(mag1) * Math.Sqrt(mag2)));
        }
    }
}
