using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace tripTicket.Services.Migrations
{
    /// <inheritdoc />
    public partial class SeedData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
    table: "Roles",
    columns: new[] { "Id", "Name" },
    values: new object[,]
    {
         { 1, "Admin" },
         { 2, "User" }
    });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "FirstName", "LastName", "Username", "Email", "Phone", "PasswordHash", "PasswordSalt", "BirthDate", "IsDeleted", "CreatedAt" },
                values: new object[,] {
         { 1, "Admin", "Admin", "admin", "admin@example.com", "1234567890", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(2000, 1, 1), false, DateTime.UtcNow },
         { 2, "Test", "User", "testuser", "test@example.com", "1234567890", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(2000, 1, 1), false, DateTime.UtcNow },
         { 3, "Faris", "Dizdarevic", "faris", "faris.diz789@gmail.com", "0603360416", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(2000, 1, 1), false, DateTime.UtcNow },
         { 4, "Emily", "Johnson", "emilyj", "emily.johnson@example.com", "3456789012", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(1988, 11, 12), false, DateTime.UtcNow },
         { 5, "Michael", "Brown", "michaelb", "michael.brown@example.com", "4567890123", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(1992, 3, 3), false, DateTime.UtcNow },
         { 6, "Jessica", "Davis", "jessicad", "jessica.davis@example.com", "5678901234", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(1990, 7, 15), false, DateTime.UtcNow },
         { 7, "David", "Miller", "davidm", "david.miller@example.com", "6789012345", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(1985, 12, 1), false, DateTime.UtcNow },
         { 8, "Sarah", "Wilson", "sarahw", "sarah.wilson@example.com", "7890123456", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(1998, 9, 9), false, DateTime.UtcNow },
         { 9, "Daniel", "Moore", "danielmoore", "daniel.moore@example.com", "8901234567", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(1993, 4, 22), false, DateTime.UtcNow },
         { 10, "Laura", "Taylor", "laurat", "laura.taylor@example.com", "9012345678", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(1997, 8, 30), false, DateTime.UtcNow }
                });

            migrationBuilder.InsertData(
                table: "UserRoles",
                columns: new[] { "Id", "UserId", "RoleId" },
                values: new object[,]
                {
         { 1, 1, 1 },  // Admin user gets Admin role
         { 2, 2, 2 },
         { 3, 3, 2 },
         { 4, 4, 2 },
         { 5, 5, 2 },
         { 6, 6, 2 },
         { 7, 7, 2 },
         { 8, 8, 2 },
         { 9, 9, 2 },
         { 10, 10, 2 }
                });

            migrationBuilder.InsertData(
                table: "Countries",
                columns: new[] { "Id", "Name", "CountryCode", "IsActive" },
                values: new object[,]
                {
         { 1, "France", "FR", true },
         { 2, "Germany", "DE", true },
         { 3, "Italy", "IT", true },
         { 4, "Spain", "ES", true },
         { 5, "USA", "US", true },
         { 6, "Canada", "CA", true },
         { 7, "Japan", "JP", true },
         { 8, "Brazil", "BR", true },
         { 9, "Australia", "AU", true },
         { 10, "Netherlands", "NL", true }
                });

            migrationBuilder.InsertData(
                table: "Cities",
                columns: new[] { "Id", "Name", "CountryId", "IsActive" },
                values: new object[,]
                {
         // France
         { 1, "Paris", 1, true },
         { 2, "Lyon", 1, true },
         { 3, "Marseille", 1, true },

         // Germany
         { 4, "Berlin", 2, true },
         { 5, "Munich", 2, true },
         { 6, "Hamburg", 2, true },

         // Italy
         { 7, "Rome", 3, true },
         { 8, "Milan", 3, true },
         { 9, "Venice", 3, true },

         // Spain
         { 10, "Madrid", 4, true },
         { 11, "Barcelona", 4, true },
         { 12, "Valencia", 4, true },

         // USA
         { 13, "New York", 5, true },
         { 14, "Los Angeles", 5, true },
         { 15, "Chicago", 5, true },

         // Canada
         { 16, "Toronto", 6, true },
         { 17, "Vancouver", 6, true },
         { 18, "Montreal", 6, true },

         // Japan
         { 19, "Tokyo", 7, true },
         { 20, "Osaka", 7, true },
         { 21, "Kyoto", 7, true },

         // Brazil
         { 22, "Rio de Janeiro", 8, true },
         { 23, "São Paulo", 8, true },
         { 24, "Brasília", 8, true },

         // Australia
         { 25, "Sydney", 9, true },
         { 26, "Melbourne", 9, true },
         { 27, "Brisbane", 9, true },

         // Netherlands
         { 28, "Amsterdam", 10, true },
         { 29, "Rotterdam", 10, true },
         { 30, "Utrecht", 10, true }
                });


            migrationBuilder.InsertData(
                table: "Trips",
                columns: new[] {
     "Id", "CityId", "DepartureCityId", "DepartureDate", "ReturnDate", "TicketSaleEnd",
     "TripType", "TransportType", "TicketPrice", "AvailableTickets", "PurchasedTickets", "Description",
     "FreeCancellationUntil", "CancellationFee", "MinTicketsForDiscount", "DiscountPercentage", "Photo",
     "TripStatus", "IsCanceled", "CreatedAt"
                        },
                        values: new object[,] {
     { 1, 1, 4, new DateOnly(2025, 7, 1), new DateOnly(2025, 7, 10), DateTime.UtcNow.AddDays(20), "Vacation", "Bus", 1200.50m, 100, 25, "A relaxing 10-day trip to Paris.", new DateOnly(2025, 6, 20), 50m, 5, 10m, null, "upcoming", false, DateTime.UtcNow },
     { 2, 7, 5, new DateOnly(2025, 8, 15), new DateOnly(2025, 8, 25), DateTime.UtcNow.AddDays(30), "Historical", "Train", 800.00m, 50, 10, "Explore the ancient ruins and culture of Rome.", null, null, null, null, null, "upcoming", false, DateTime.UtcNow },
     { 3, 13, 15, new DateOnly(2025, 9, 5), new DateOnly(2025, 9, 15), DateTime.UtcNow.AddDays(40), "City Tour", "Plane", 1500.75m, 80, 40, "Experience the Big Apple and its vibrant life.", new DateOnly(2025, 8, 25), 75m, 3, 15m, null, "upcoming", false, DateTime.UtcNow },
     { 4, 19, 20, new DateOnly(2025, 10, 10), new DateOnly(2025, 10, 20), DateTime.UtcNow.AddDays(50), "Cultural", "Bus", 1800.00m, 60, 12, "Discover the rich culture and tech in Tokyo.", new DateOnly(2025, 9, 30), 100m, 4, 12m, null, "upcoming", false, DateTime.UtcNow },
     { 5, 25, 26, new DateOnly(2025, 11, 1), new DateOnly(2025, 11, 10), DateTime.UtcNow.AddDays(55), "Adventure", "Plane", 2200.00m, 40, 5, "Explore Sydney's beautiful harbor and beaches.", null, null, null, null, null, "upcoming", false, DateTime.UtcNow },
     { 6, 11, 2, new DateOnly(2025, 7, 15), new DateOnly(2025, 7, 22), DateTime.UtcNow.AddDays(25), "City Tour", "Bus", 700.00m, 120, 60, "Visit Barcelona's architecture and beaches.", new DateOnly(2025, 7, 5), 30m, 6, 8m, null, "upcoming", false, DateTime.UtcNow },
     { 7, 22, 23, new DateOnly(2025, 8, 5), new DateOnly(2025, 8, 15), DateTime.UtcNow.AddDays(35), "Beach", "Bus", 1300.00m, 55, 15, "Sunbathe on Copacabana and experience carnival vibes.", null, null, null, null, null, "upcoming", false, DateTime.UtcNow },
     { 8, 17, 18, new DateOnly(2025, 9, 20), new DateOnly(2025, 9, 28), DateTime.UtcNow.AddDays(45), "Nature", "Car", 900.00m, 70, 20, "Explore the mountains and coastlines of Vancouver.", null, null, null, null, null, "upcoming", false, DateTime.UtcNow },
     { 9, 28, 29, new DateOnly(2025, 10, 25), new DateOnly(2025, 11, 2), DateTime.UtcNow.AddDays(60), "City Tour", "Train", 1100.00m, 90, 35, "Cycle through historic canals and museums.", new DateOnly(2025, 10, 15), 40m, 7, 9m, null, "upcoming", false, DateTime.UtcNow },
     { 10, 8, 14, new DateOnly(2025, 12, 5), new DateOnly(2025, 12, 15), DateTime.UtcNow.AddDays(70), "Fashion", "Plane", 1450.00m, 65, 22, "Milan fashion tour and luxury experience.", new DateOnly(2025, 11, 20), 60m, 3, 11m, null, "upcoming", false, DateTime.UtcNow }
                });

            migrationBuilder.InsertData(
                table: "TripDays",
                columns: new[] { "Id", "TripId", "DayNumber", "Title" },
                values: new object[,]
                {
         { 1, 1, 1, "Arrival and City Tour" },
         { 2, 1, 2, "Mountain Hiking" },
         { 3, 1, 3, "Relax at the Beach" },
         { 4, 2, 1, "Explore Downtown" },
         { 5, 2, 2, "Museum Visit" },
         { 6, 2, 3, "Local Food Tasting" },
         { 7, 3, 1, "Arrival and Leisure" },
         { 8, 3, 2, "Historic Sites" },
         { 9, 3, 3, "Boat Tour" },
         { 10, 4, 1, "Arrival and City Walk" },
         { 11, 4, 2, "Mountain Bike Adventure" },
         { 12, 4, 3, "Local Market Shopping" },
         { 13, 5, 1, "Arrival and Sightseeing" },
         { 14, 5, 2, "Visit National Park" },
         { 15, 5, 3, "Relaxing Spa Day" },
         { 16, 6, 1, "Arrival and Beach Time" },
         { 17, 6, 2, "Snorkeling" },
         { 18, 6, 3, "Sunset Dinner" },
         { 19, 7, 1, "Arrival and City Tour" },
         { 20, 7, 2, "Museum and Galleries" },
         { 21, 7, 3, "Local Theater Show" },
         { 22, 8, 1, "Arrival and Hiking" },
         { 23, 8, 2, "River Rafting" },
         { 24, 8, 3, "Campfire Night" },
         { 25, 9, 1, "Arrival and City Walk" },
         { 26, 9, 2, "Wine Tasting" },
         { 27, 9, 3, "Historic Castle Visit" },
         { 28, 10, 1, "Arrival and Market Tour" },
         { 29, 10, 2, "Beach and Water Sports" },
         { 30, 10, 3, "Farewell Dinner" }
                });

            migrationBuilder.InsertData(
                table: "TripDayItems",
                columns: new[] { "Id", "TripDayId", "Time", "Action", "OrderNumber" },
                values: new object[,]
                {
         { 1, 1, new TimeOnly(9, 0), "Arrive at airport and transfer to hotel", 1 },
         { 2, 1, new TimeOnly(11, 0), "Guided city tour", 2 },
         { 3, 1, new TimeOnly(18, 0), "Welcome dinner at local restaurant", 3 },
         { 4, 2, new TimeOnly(7, 30), "Breakfast at hotel", 1 },
         { 5, 2, new TimeOnly(9, 0), "Start mountain hiking", 2 },
         { 6, 2, new TimeOnly(16, 0), "Return to hotel and rest", 3 },
         { 7, 3, new TimeOnly(10, 0), "Breakfast", 1 },
         { 8, 3, new TimeOnly(11, 0), "Relax at the beach", 2 },
         { 9, 3, new TimeOnly(19, 0), "Beach barbecue", 3 },
         { 10, 4, new TimeOnly(9, 0), "Breakfast at local cafe", 1 },
         { 11, 4, new TimeOnly(10, 30), "Walk downtown and shopping", 2 },
         { 12, 4, new TimeOnly(18, 0), "Dinner at downtown bistro", 3 },
         { 13, 5, new TimeOnly(9, 0), "Breakfast", 1 },
         { 14, 5, new TimeOnly(10, 0), "Visit city museum", 2 },
         { 15, 5, new TimeOnly(15, 0), "Coffee break", 3 },
         { 16, 6, new TimeOnly(12, 0), "Local food tasting tour", 1 },
         { 17, 6, new TimeOnly(15, 0), "Visit food market", 2 },
         { 18, 6, new TimeOnly(19, 0), "Dinner with tasting menu", 3 },
         { 19, 7, new TimeOnly(9, 0), "Arrival and hotel check-in", 1 },
         { 20, 7, new TimeOnly(12, 0), "Free time to relax", 2 },
         { 21, 7, new TimeOnly(18, 0), "Dinner at hotel", 3 },
         { 22, 8, new TimeOnly(9, 0), "Breakfast", 1 },
         { 23, 8, new TimeOnly(10, 0), "Visit historic sites tour", 2 },
         { 24, 8, new TimeOnly(17, 0), "Evening stroll", 3 },
         { 25, 9, new TimeOnly(10, 0), "Boat tour of the bay", 1 },
         { 26, 9, new TimeOnly(13, 0), "Lunch on board", 2 },
         { 27, 9, new TimeOnly(16, 0), "Return to hotel", 3 },
         { 28, 10, new TimeOnly(9, 0), "Arrive and check-in", 1 },
         { 29, 10, new TimeOnly(11, 0), "City walking tour", 2 },
         { 30, 10, new TimeOnly(18, 0), "Dinner at local restaurant", 3 },
                });

            migrationBuilder.InsertData(
                table: "TripStatistics",
                columns: new[] { "Id", "TripId", "TotalViews", "TotalRevenue", "TotalDiscountsApplied", "TotalTicketsSold", "LastUpdated" },
                values: new object[,]
                {
         { 1, 1, 1250, 37500.00m, 1500.00m, 150, DateTime.UtcNow.AddDays(-1) },
         { 2, 2, 980, 24500.00m, 1200.00m, 100, DateTime.UtcNow.AddDays(-2) },
         { 3, 3, 700, 21000.00m, 900.00m, 90, DateTime.UtcNow.AddDays(-3) },
         { 4, 4, 1340, 40200.00m, 1800.00m, 160, DateTime.UtcNow.AddDays(-1) },
         { 5, 5, 560, 11200.00m, 600.00m, 80, DateTime.UtcNow.AddDays(-5) },
         { 6, 6, 890, 26700.00m, 1100.00m, 110, DateTime.UtcNow.AddDays(-2) },
         { 7, 7, 720, 21600.00m, 700.00m, 90, DateTime.UtcNow.AddDays(-4) },
         { 8, 8, 450, 13500.00m, 400.00m, 75, DateTime.UtcNow.AddDays(-7) },
         { 9, 9, 980, 29400.00m, 1300.00m, 105, DateTime.UtcNow.AddDays(-2) },
         { 10, 10, 670, 20100.00m, 800.00m, 85, DateTime.UtcNow.AddDays(-3) }
                });

            migrationBuilder.InsertData(
                table: "UserActivity",
                columns: new[] { "UserActivityId", "UserId", "ActionType", "ActionDate", "TripId", "PurchaseId", "AdditionalInfo" },
                values: new object[,]
                {
         { 1, 1, "Login", DateTime.UtcNow.AddDays(-10), null, null, null },
         { 2, 1, "BookmarkTrip", DateTime.UtcNow.AddDays(-9), 3, null, null },
         { 3, 1, "PurchaseTicket", DateTime.UtcNow.AddDays(-8), 3, "PUR1", "Bought 2 tickets" },
         { 4, 2, "Login", DateTime.UtcNow.AddDays(-7), null, null, null },
         { 5, 2, "BookmarkTrip", DateTime.UtcNow.AddDays(-6), 5, null, null },
         { 6, 2, "PurchaseTicket", DateTime.UtcNow.AddDays(-5), 5, "PUR2", "Bought 1 ticket" },
         { 7, 2, "CancelPurchase", DateTime.UtcNow.AddDays(-3), 5, "PUR2", "Canceled purchase" },
         { 8, 3, "Login", DateTime.UtcNow.AddDays(-4), null, null, null },
         { 9, 3, "BookmarkTrip", DateTime.UtcNow.AddDays(-3), 7, null, null },
         { 10, 3, "PurchaseTicket", DateTime.UtcNow.AddDays(-2), 7, "PUR3", "Bought 4 tickets" },
         { 11, 4, "Login", DateTime.UtcNow.AddDays(-1), null, null, null },
         { 12, 4, "BookmarkTrip", DateTime.UtcNow, 1, null, null }
                });

            migrationBuilder.InsertData(
                table: "Bookmarks",
                columns: new[] { "Id", "UserId", "TripId", "CreatedAt" },
                values: new object[,]
                {
         { 1, 1, 1, DateTime.UtcNow.AddDays(-10) },
         { 2, 1, 3, DateTime.UtcNow.AddDays(-7) },
         { 3, 2, 2, DateTime.UtcNow.AddDays(-5) },
         { 4, 2, 5, DateTime.UtcNow.AddDays(-3) },
         { 5, 3, 4, DateTime.UtcNow.AddDays(-1) },
         { 6, 3, 6, DateTime.UtcNow },
         { 7, 1, 7, DateTime.UtcNow.AddDays(-2) },
         { 8, 2, 8, DateTime.UtcNow.AddDays(-4) },
         { 9, 3, 9, DateTime.UtcNow.AddDays(-6) },
         { 10, 1, 10, DateTime.UtcNow.AddDays(-8) }
                });

            migrationBuilder.InsertData(
                table: "Purchases",
                columns: new[] { "Id", "TripId", "UserId", "NumberOfTickets", "TotalPayment", "Discount", "CreatedAt", "Status", "PaymentMethod" },
                values: new object[,]
                {
         { 1, 1, 2, 2, 300m, 0m, DateTime.UtcNow.AddDays(-10), "complete", "Stripe" },
         { 2, 3, 3, 1, 150m, null, DateTime.UtcNow.AddDays(-9), "complete", "Stripe" },
         { 3, 4, 4, 4, 600m, 10m, DateTime.UtcNow.AddDays(-8), "complete", "Stripe" },
         { 4, 5, 5, 1, 180m, null, DateTime.UtcNow.AddDays(-7), "accepted", "Stripe" },
         { 5, 6, 6, 3, 450m, 15m, DateTime.UtcNow.AddDays(-6), "complete", "Stripe" },
         { 6, 7, 7, 2, 300m, 0m, DateTime.UtcNow.AddDays(-5), "complete", "Stripe" },
         { 7, 8, 8, 5, 750m, 25m, DateTime.UtcNow.AddDays(-4), "complete", "Stripe" },
         { 8, 9, 9, 1, 150m, null, DateTime.UtcNow.AddDays(-3), "complete", "Stripe" },
         { 9, 10, 10, 2, 300m, 0m, DateTime.UtcNow.AddDays(-2), "accepted", "Stripe" },
         { 10, 2, 2, 1, 120m, null, DateTime.UtcNow.AddDays(-1), "complete", "Stripe" }
                });

            migrationBuilder.InsertData(
                table: "Transactions",
                columns: new[] { "Id", "PurchaseId", "Amount", "Status", "PaymentMethod", "TransactionDate", "StripeTransactionId" },
                values: new object[,]
                {
         { "txn_0001", 1, 2401.00m, "succeeded", "Stripe", DateTime.UtcNow.AddDays(-12), "stripe_txn_0001" },
         { "txn_0002", 2, 1500.75m, "succeeded", "Stripe", DateTime.UtcNow.AddDays(-8), "stripe_txn_0002" },
         { "txn_0003", 3, 2200.00m, "succeeded", "Stripe", DateTime.UtcNow.AddDays(-7), "stripe_txn_0003" },
         { "txn_0004", 4, 2200.00m, "succeeded", "Stripe", DateTime.UtcNow.AddDays(-3), "stripe_txn_0004" },
         { "txn_0005", 5, 6900.00m, "succeeded", "Stripe", DateTime.UtcNow.AddDays(-5), "stripe_txn_0005" },
         { "txn_0006", 6, 1400.00m, "succeeded", "Stripe", DateTime.UtcNow.AddDays(-1), "stripe_txn_0006" },
         { "txn_0007", 7, 1400.00m, "succeeded", "Stripe", DateTime.UtcNow.AddDays(-2), "stripe_txn_0007" },
         { "txn_0008", 8, 1700.00m, "succeeded", "Stripe", DateTime.UtcNow.AddDays(-4), "stripe_txn_0008" },
         { "txn_0009", 9, 3150.00m, "succeeded", "Stripe", DateTime.UtcNow.AddDays(-6), "stripe_txn_0009" },
         { "txn_0010", 10, 1300.00m, "succeeded", "Stripe", DateTime.UtcNow.AddDays(-10), "stripe_txn_0010" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {

        }
    }
}
