using System;
using System.Collections.Generic;

namespace tripTicket.Services.Database;

public partial class User
{
    public int Id { get; set; }

    public string FirstName { get; set; } = null!;

    public string LastName { get; set; } = null!;
    public string Username { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string? Phone { get; set; }

    public string PasswordHash { get; set; } = null!;

    public string PasswordSalt { get; set; } = null!;

    public DateOnly BirthDate { get; set; }

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual ICollection<Bookmark> Bookmarks { get; set; } = new List<Bookmark>();
    public virtual ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
    public virtual ICollection<UserRecommendation> Recommendations { get; set; } = new List<UserRecommendation>();
    public virtual ICollection<SupportTicket> SupportTickets { get; set; } = new List<SupportTicket>();
    public virtual ICollection<SupportReply> SupportReplies { get; set; } = new List<SupportReply>();
    public virtual ICollection<TripReview> TripReviews { get; set; } = new List<TripReview>();
}
