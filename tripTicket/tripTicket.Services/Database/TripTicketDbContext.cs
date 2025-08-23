using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Stripe;

namespace tripTicket.Services.Database;

public partial class TripTicketDbContext : DbContext
{
    public TripTicketDbContext()
    {
    }

    public TripTicketDbContext(DbContextOptions<TripTicketDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Bookmark> Bookmarks { get; set; }

    public virtual DbSet<Purchase> Purchases { get; set; }

    public virtual DbSet<Transaction> Transactions { get; set; }

    public virtual DbSet<Country> Countries { get; set; }

    public virtual DbSet<City> Cities { get; set; }

    public virtual DbSet<Trip> Trips { get; set; }

    public virtual DbSet<TripDay> TripDays { get; set; }

    public virtual DbSet<TripDayItem> TripDayItems { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<Role> Roles { get; set; }
    public virtual DbSet<UserRole> UserRoles { get; set; }
    public virtual DbSet<UserRecommendation> UserRecommendations { get; set; }
    public virtual DbSet<SupportTicket> SupportTickets { get; set; }
    public virtual DbSet<SupportReply> SupportReplies { get; set; }
    public virtual DbSet<TripReview> TripReviews { get; set; }

//    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
//#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
//        => optionsBuilder.UseSqlServer("Data Source=localhost, 1433;Initial Catalog=TripTicketDB; user=sa; Password=QWEasd123!; TrustServerCertificate=True");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Bookmark>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Bookmark__541A3B713D54E270");

            entity.HasIndex(e => new { e.UserId, e.TripId }, "UQ_Bookmarks_User_Trip").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");

            entity.HasOne(d => d.Trip).WithMany(p => p.Bookmarks)
                .HasForeignKey(d => d.TripId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Bookmarks_Trip");

            entity.HasOne(d => d.User).WithMany(p => p.Bookmarks)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Bookmarks_User");
        });

        modelBuilder.Entity<Purchase>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Purchase__3214EC07591365F4");

            entity.Property(e => e.Id)
                .HasMaxLength(8)
                .IsUnicode(false)
                .IsFixedLength();
            entity.Property(e => e.CreatedAt).HasColumnType("datetime");
            entity.Property(e => e.Discount).HasColumnType("decimal(5, 2)");
            entity.Property(e => e.PaymentMethod)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.Status)
                .HasMaxLength(20)
                .IsUnicode(false);
            entity.Property(e => e.TotalPayment).HasColumnType("decimal(10, 2)");
        });

        modelBuilder.Entity<Transaction>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Transact__3214EC07E2C01878");

            entity.Property(e => e.Id)
                .HasMaxLength(8)
                .IsUnicode(false)
                .IsFixedLength();
            entity.Property(e => e.Amount).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.PaymentMethod)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.PurchaseId)
                .HasMaxLength(8)
                .IsUnicode(false)
                .IsFixedLength();
            entity.Property(e => e.Status)
                .HasMaxLength(20)
                .IsUnicode(false);
            entity.Property(e => e.StripeTransactionId)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.TransactionDate).HasColumnType("datetime");

            entity.HasOne(d => d.Purchase).WithMany(p => p.Transactions)
                .HasForeignKey(d => d.PurchaseId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Transacti__Purch__49C3F6B7");
        });

        modelBuilder.Entity<Country>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.Property(e => e.Name).HasMaxLength(100).IsRequired();
            entity.Property(e => e.CountryCode).HasMaxLength(10).IsRequired();
        });

        modelBuilder.Entity<City>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.Property(e => e.Name).HasMaxLength(100).IsRequired();

            entity.HasOne(e => e.Country)
                .WithMany(c => c.Cities)
                .HasForeignKey(e => e.CountryId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Trip>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Trips__3214EC070626FA74");

            entity.Property(e => e.CancellationFee).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");

            entity.Property(e => e.Description).HasMaxLength(300);
            entity.Property(e => e.DiscountPercentage).HasColumnType("decimal(5, 2)");
            entity.Property(e => e.TicketPrice).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.TicketSaleEnd).HasColumnType("datetime");
            entity.Property(e => e.TransportType).HasMaxLength(50);

            entity.Property(e => e.TripStatus)
                .HasMaxLength(20)
                .HasDefaultValue("Upcoming");

            entity.Property(e => e.TripType).HasMaxLength(50);

            entity.HasOne(e => e.City)
                .WithMany(c => c.Trips)
                .HasForeignKey(e => e.CityId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(e => e.DepartureCity)
                .WithMany()
                .HasForeignKey(e => e.DepartureCityId)
                .OnDelete(DeleteBehavior.Restrict);

        });

        modelBuilder.Entity<TripDay>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__TripDays__3214EC07B361AFC1");

            entity.Property(e => e.Title).HasMaxLength(100);

            entity.HasOne(d => d.Trip).WithMany(p => p.TripDays)
                .HasForeignKey(d => d.TripId)
                .HasConstraintName("FK__TripDays__TripId__4222D4EF");
        });

        modelBuilder.Entity<TripDayItem>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__TripDayI__3214EC07A190E9A4");

            entity.Property(e => e.Action).HasMaxLength(255);

            entity.HasOne(d => d.TripDay).WithMany(p => p.TripDayItems)
                .HasForeignKey(d => d.TripDayId)
                .HasConstraintName("FK__TripDayIt__TripD__44FF419A");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Users__3214EC072EFF9310");

            entity.HasIndex(e => e.Email, "UQ__Users__A9D105340E77BC21").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Email).HasMaxLength(100);
            entity.Property(e => e.FirstName).HasMaxLength(50);
            entity.Property(e => e.LastName).HasMaxLength(50);
            entity.Property(e => e.Phone).HasMaxLength(20);
        });

        modelBuilder.Entity<SupportTicket>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Subject).IsRequired();
            entity.Property(e => e.Message).IsRequired();
            entity.Property(e => e.Status).HasMaxLength(50).IsRequired();
            entity.Property(e => e.CreatedAt).IsRequired();

            entity.HasOne(e => e.User)
                  .WithMany(u => u.SupportTickets)
                  .HasForeignKey(e => e.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<UserRecommendation>(b =>
        {
            b.ToTable("UserRecommendations");
            b.HasKey(x => x.Id);

            b.HasIndex(x => new { x.UserId, x.TripId }).IsUnique();

            b.HasOne(x => x.User)
             .WithMany(u => u.Recommendations)
             .HasForeignKey(x => x.UserId)
             .OnDelete(DeleteBehavior.Cascade);

            b.HasOne(x => x.Trip)
             .WithMany(t => t.UserRecommendations)
             .HasForeignKey(x => x.TripId)
             .OnDelete(DeleteBehavior.Cascade);

            b.Property(x => x.Score).HasColumnType("decimal(6,5)");

            b.Property(x => x.CreatedAt)
             .HasDefaultValueSql("GETUTCDATE()");
        });

        modelBuilder.Entity<SupportReply>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Message).IsRequired();
            entity.Property(e => e.CreatedAt).IsRequired();

            entity.HasOne(e => e.Ticket)
                  .WithMany(t => t.Replies)
                  .HasForeignKey(e => e.TicketId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<TripReview>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.Property(e => e.Rating).IsRequired();
            entity.Property(e => e.CreatedAt).IsRequired();

            entity.HasOne(e => e.Trip)
                  .WithMany(t => t.TripReviews)
                  .HasForeignKey(e => e.TripId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.User)
                  .WithMany(u => u.TripReviews)
                  .HasForeignKey(e => e.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });


        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
