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
    public class TripReviewService : BaseCRUDService<Model.Models.TripReview, TripReviewSearchObject, Database.TripReview, TripReviewInsertRequest, TripReviewUpdateRequest>, ITripReviewService
    {
        public TripReviewService(TripTicketDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override void BeforeInsert(TripReviewInsertRequest request, TripReview entity)
        {
            base.BeforeInsert(request, entity);

            if (request.Rating < 1 || request.Rating > 5)
                throw new UserException("Rating must be between 1 and 5.");

            var user = Context.Users.Any(u => u.Id == request.UserId);
            if (!user)
                throw new UserException("User does not exist.");

            var trip = Context.Trips.FirstOrDefault(t => t.Id == request.TripId);
            if (trip == null)
                throw new UserException("Trip does not exist.");

            if (trip.TripStatus != "complete")
            {
                throw new UserException("You can only review trip after it is completed");
            }

            var purchased = Context.Purchases
                .Any(p => p.UserId == request.UserId && p.TripId == request.TripId && p.Status == "complete");

            if (!purchased)
                throw new UserException("You can only review trips you have purchased tickets for");

            var alreadyReviewed = Context.TripReviews
                .Any(r => r.TripId == request.TripId && r.UserId == request.UserId);

            if (alreadyReviewed)
                throw new UserException("You have already reviewed this trip.");
        }

        public override PagedResult<Model.Models.TripReview> GetPaged(TripReviewSearchObject search)
        {
            List<Model.Models.TripReview> result = new List<Model.Models.TripReview>();

            var query = Context.Set<Database.TripReview>()
                .Include(t => t.User)
                .AsQueryable();

            query = AddFilter(search, query);

            int count = query.Count();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = query.ToList();

            result = Mapper.Map(list, result);

            PagedResult<Model.Models.TripReview> pagedResult = new PagedResult<Model.Models.TripReview>();
            pagedResult.ResultList = result;
            pagedResult.Count = count;

            return pagedResult;
        }

        public override IQueryable<TripReview> AddFilter(TripReviewSearchObject search, IQueryable<TripReview> query)
        {
            query = base.AddFilter(search, query);

            if (search.TripId.HasValue)
            {
                query = query.Where(t => t.TripId ==  search.TripId.Value);
            }

            query = query.OrderByDescending(t => t.CreatedAt);

            return query;
        }

        public double GetAverageRating(int tripId)
        {
            var reviews = Context.TripReviews
                .Where(r => r.TripId == tripId);

            if (!reviews.Any())
                return 0;

            return Math.Round(reviews.Average(r => r.Rating), 2);
        }

        public void DeleteReview(int id)
        {
            var review = Context.TripReviews.FirstOrDefault(r => r.Id == id);

            if (review == null)
                throw new UserException("Review not found.");

            Context.TripReviews.Remove(review);
            Context.SaveChanges();
        }
    }
}
