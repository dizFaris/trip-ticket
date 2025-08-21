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
                columns: new[] { "Id", "FirstName", "LastName", "Username", "Email", "Phone", "PasswordHash", "PasswordSalt", "BirthDate", "IsActive", "CreatedAt" },
                values: new object[,] {
                    { 1, "Admin", "Admin", "admin", "admin@example.com", "1234567890", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(2000, 1, 1), true, DateTime.UtcNow },
                    { 2, "Test", "User", "testuser", "test@example.com", "1234567890", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(2000, 1, 1), true, DateTime.UtcNow },
                    { 3, "Faris", "Dizdarevic", "faris", "faris.diz789@gmail.com", "0603360416", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(2000, 1, 1), true, DateTime.UtcNow },
                    { 4, "Emily", "Johnson", "emilyj", "emily.johnson@example.com", "3456789012", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(1988, 11, 12), true, DateTime.UtcNow },
                    { 5, "Michael", "Brown", "michaelb", "michael.brown@example.com", "4567890123", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(1992, 3, 3), true, DateTime.UtcNow },
                    { 6, "Jessica", "Davis", "jessicad", "jessica.davis@example.com", "5678901234", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(1990, 7, 15), true, DateTime.UtcNow },
                    { 7, "David", "Miller", "davidm", "david.miller@example.com", "6789012345", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(1985, 12, 1), true, DateTime.UtcNow },
                    { 8, "Sarah", "Wilson", "sarahw", "sarah.wilson@example.com", "7890123456", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(1998, 9, 9), true, DateTime.UtcNow },
                    { 9, "Daniel", "Moore", "danielmoore", "daniel.moore@example.com", "8901234567", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(1993, 4, 22), true, DateTime.UtcNow },
                    { 10, "Laura", "Taylor", "laurat", "laura.taylor@example.com", "9012345678", "fbUwB9Q69z7aYVUaaw+1o8UTlM0=", "PRnruT43mLsmBSxHAtJ3oQ==", new DateOnly(1997, 8, 30), true, DateTime.UtcNow }
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
                values: new object[,]
                {
                    { 1, 1, 4, new DateOnly(2025, 2, 10), new DateOnly(2025, 2, 17),
                        new DateOnly(2025, 2, 7).ToDateTime(TimeOnly.MinValue),
                        "Historical", "Train", 550.00m, 80, 60, "Discover ancient Rome in a guided cultural trip.",
                        null, null, null, null, null, "complete", false, new DateTime(2025, 2, 1) },

                    { 2, 2, 5, new DateOnly(2025, 3, 5), new DateOnly(2025, 3, 12),
                        new DateOnly(2025, 3, 2).ToDateTime(TimeOnly.MinValue),
                        "Beach", "Plane", 750.00m, 70, 65, "Relax on sunny beaches in Barcelona.",
                        null, null, null, null, null, "complete", false, new DateTime(2025, 3, 1) },

                    { 3, 3, 6, new DateOnly(2025, 4, 1), new DateOnly(2025, 4, 7),
                      new DateOnly(2025, 3, 29).ToDateTime(TimeOnly.MinValue),
                      "City Tour", "Bus", 300.00m, 90, 40, "Short trip to Berlin with guided tours.",
                      new DateOnly(2025, 3, 25), 25m, 4, 7m, null, "canceled", true, DateTime.UtcNow },

                    { 4, 4, 7, new DateOnly(2025, 9, 4), new DateOnly(2025, 9, 11),
                        new DateOnly(2025, 9, 1).ToDateTime(TimeOnly.MinValue),
                        "Romantic", "Car", 450.00m, 50, 0, "Romantic getaway in Vienna.",
                        null, null, null, null, null, "upcoming", false, new DateTime(2025, 8, 21) },

                    { 5, 5, 8, new DateOnly(2025, 9, 12), new DateOnly(2025, 9, 19),
                        new DateOnly(2025, 9, 9).ToDateTime(TimeOnly.MinValue),
                        "Eco-tourism", "Bike", 280.00m, 40, 0, "Cycling eco-tour through the Netherlands.",
                        null, null, null, null, null, "upcoming", false, new DateTime(2025, 8, 21) },

                    { 6, 6, 9, new DateOnly(2025, 9, 20), new DateOnly(2025, 9, 27),
                        new DateOnly(2025, 9, 17).ToDateTime(TimeOnly.MinValue),
                        "Adventure", "Plane", 920.00m, 60, 0, "Adventure tour in the Alps.",
                        new DateOnly(2025, 9, 13), 40m, 5, 10m, null, "upcoming", false, new DateTime(2025, 8, 21) },

                    { 7, 7, 10, new DateOnly(2025, 9, 28), new DateOnly(2025, 10, 5),
                        new DateOnly(2025, 9, 25).ToDateTime(TimeOnly.MinValue),
                        "Luxury", "Train", 980.00m, 45, 0, "Luxury train journey across Switzerland.",
                        new DateOnly(2025, 9, 21), 60m, 3, 12m, null, "upcoming", false, new DateTime(2025, 8, 21) },

                    { 8, 8, 11, new DateOnly(2025, 10, 6), new DateOnly(2025, 10, 13),
                        new DateOnly(2025, 10, 3).ToDateTime(TimeOnly.MinValue),
                        "Cultural", "Bus", 600.00m, 75, 0, "Cultural highlights of Prague.",
                        null, null, null, null, null, "upcoming", false, new DateTime(2025, 8, 21) },

                    { 9, 9, 12, new DateOnly(2025, 10, 14), new DateOnly(2025, 10, 21),
                        new DateOnly(2025, 10, 11).ToDateTime(TimeOnly.MinValue),
                        "Family", "Car", 480.00m, 100, 0, "Family road trip through Austria.",
                        new DateOnly(2025, 10, 7), 35m, 6, 9m, null, "upcoming", false, new DateTime(2025, 8, 21) },

                    { 10, 10, 13, new DateOnly(2025, 10, 22), new DateOnly(2025, 10, 29),
                        new DateOnly(2025, 10, 19).ToDateTime(TimeOnly.MinValue),
                        "Wellness", "Plane", 890.00m, 65, 0, "Wellness retreat in Bali.",
                        null, null, null, null, null, "upcoming", false, new DateTime(2025, 8, 21) },

                    { 11, 11, 14, new DateOnly(2025, 10, 30), new DateOnly(2025, 11, 6),
                        new DateOnly(2025, 10, 27).ToDateTime(TimeOnly.MinValue),
                        "Safari", "Bus", 970.00m, 55, 0, "Safari in Kenya with experienced guides.",
                        new DateOnly(2025, 10, 23), 70m, 4, 14m, null, "upcoming", false, new DateTime(2025, 8, 21) },

                    { 12, 12, 15, new DateOnly(2025, 11, 7), new DateOnly(2025, 11, 14),
                        new DateOnly(2025, 11, 4).ToDateTime(TimeOnly.MinValue),
                        "Nature", "Boat", 640.00m, 70, 0, "Boat trip exploring Norway’s fjords.",
                        null, null, null, null, null, "upcoming", false, new DateTime(2025, 8, 21) },
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
                    { 11, 4, 2, "Romantic Dinner" },
                    { 12, 4, 3, "Countryside Drive" },
                    { 13, 5, 1, "Arrival and Sightseeing" },
                    { 14, 5, 2, "Visit National Park" },
                    { 15, 5, 3, "Cycling Adventure" },
                    { 16, 6, 1, "Arrival and Beach Time" },
                    { 17, 6, 2, "Alpine Hiking" },
                    { 18, 6, 3, "Sunset Dinner" },
                    { 19, 7, 1, "Arrival and Train Journey" },
                    { 20, 7, 2, "Museum and Galleries" },
                    { 21, 7, 3, "Local Theater Show" },
                    { 22, 8, 1, "Arrival and Hiking" },
                    { 23, 8, 2, "City Tour" },
                    { 24, 8, 3, "Campfire Night" },
                    { 25, 9, 1, "Arrival and City Walk" },
                    { 26, 9, 2, "Wine Tasting" },
                    { 27, 9, 3, "Historic Castle Visit" },
                    { 28, 10, 1, "Arrival and Market Tour" },
                    { 29, 10, 2, "Beach and Water Sports" },
                    { 30, 10, 3, "Farewell Dinner" },
                    { 31, 11, 1, "Arrival and Safari Introduction" },
                    { 32, 11, 2, "Wildlife Drive" },
                    { 33, 11, 3, "Evening Campfire" },
                    { 34, 12, 1, "Arrival and Boat Cruise" },
                    { 35, 12, 2, "Fjord Exploration" },
                    { 36, 12, 3, "Scenic Relaxation" }
               });

            migrationBuilder.InsertData(
                table: "TripDayItems",
                columns: new[] { "Id", "TripDayId", "Time", "Action", "OrderNumber" },
                values: new object[,]
                {
                    { 1, 1, new TimeOnly(9, 0), "Arrive at airport and transfer to hotel", 1 },
                    { 2, 1, new TimeOnly(11, 0), "Guided city tour", 2 },
                    { 3, 1, new TimeOnly(18, 0), "Welcome dinner", 3 },
                    { 4, 2, new TimeOnly(8, 0), "Breakfast at hotel", 1 },
                    { 5, 2, new TimeOnly(9, 0), "Start mountain hiking", 2 },
                    { 6, 2, new TimeOnly(16, 0), "Return and rest", 3 },
                    { 7, 3, new TimeOnly(10, 0), "Relax at the beach", 1 },
                    { 8, 3, new TimeOnly(19, 0), "Beach barbecue", 2 },
                    { 9, 4, new TimeOnly(9, 0), "Breakfast at cafe", 1 },
                    { 10, 4, new TimeOnly(10, 0), "Walk downtown", 2 },
                    { 11, 4, new TimeOnly(18, 0), "Dinner at bistro", 3 },
                    { 12, 5, new TimeOnly(9, 0), "Visit museum", 1 },
                    { 13, 5, new TimeOnly(14, 0), "Lunch", 2 },
                    { 14, 6, new TimeOnly(12, 0), "Food tasting tour", 1 },
                    { 15, 6, new TimeOnly(15, 0), "Visit market", 2 },
                    { 16, 7, new TimeOnly(9, 0), "Hotel check-in", 1 },
                    { 17, 7, new TimeOnly(12, 0), "Free time", 2 },
                    { 18, 8, new TimeOnly(10, 0), "Historic sites tour", 1 },
                    { 19, 9, new TimeOnly(10, 0), "Boat tour of the bay", 1 },
                    { 20, 10, new TimeOnly(9, 0), "Arrival walk", 1 },
                    { 21, 11, new TimeOnly(19, 0), "Romantic dinner", 1 },
                    { 22, 13, new TimeOnly(9, 0), "Arrival sightseeing", 1 },
                    { 23, 14, new TimeOnly(10, 0), "National park visit", 1 },
                    { 24, 15, new TimeOnly(15, 0), "Cycling through countryside", 1 },
                    { 25, 16, new TimeOnly(9, 0), "Beach arrival", 1 },
                    { 26, 17, new TimeOnly(10, 0), "Alpine hiking", 1 },
                    { 27, 18, new TimeOnly(18, 0), "Sunset dinner", 1 },
                    { 28, 19, new TimeOnly(9, 0), "Luxury train boarding", 1 },
                    { 29, 20, new TimeOnly(10, 0), "Visit museum", 1 },
                    { 30, 21, new TimeOnly(20, 0), "Theater show", 1 },
                    { 31, 22, new TimeOnly(9, 0), "Arrival hike", 1 },
                    { 32, 23, new TimeOnly(10, 0), "City tour", 1 },
                    { 33, 24, new TimeOnly(20, 0), "Campfire night", 1 },
                    { 34, 25, new TimeOnly(9, 0), "City walk", 1 },
                    { 35, 26, new TimeOnly(14, 0), "Wine tasting", 1 },
                    { 36, 27, new TimeOnly(16, 0), "Castle visit", 1 },
                    { 37, 28, new TimeOnly(9, 0), "Market tour", 1 },
                    { 38, 29, new TimeOnly(13, 0), "Water sports", 1 },
                    { 39, 30, new TimeOnly(19, 0), "Farewell dinner", 1 },
                    { 40, 31, new TimeOnly(9, 0), "Safari briefing", 1 },
                    { 41, 32, new TimeOnly(12, 0), "Wildlife drive", 1 },
                    { 42, 33, new TimeOnly(19, 0), "Campfire gathering", 1 },
                    { 43, 34, new TimeOnly(9, 0), "Arrival boat ride", 1 },
                    { 44, 35, new TimeOnly(11, 0), "Fjord exploration", 1 },
                    { 45, 36, new TimeOnly(16, 0), "Relax by the water", 1 }
                });

            migrationBuilder.InsertData(
                table: "Bookmarks",
                columns: new[] { "Id", "UserId", "TripId", "CreatedAt" },
                values: new object[,]
                {
                    { 1, 2, 2, new DateTime(2025, 8, 15) },
                    { 2, 2, 5, new DateTime(2025, 8, 17) },
                    { 3, 3, 4, new DateTime(2025, 8, 19) },
                    { 4, 3, 6, new DateTime(2025, 8, 20) },
                    { 5, 2, 8, new DateTime(2025, 8, 16) },
                    { 6, 3, 9, new DateTime(2025, 8, 14) }
                });

            migrationBuilder.InsertData(
                table: "Purchases",
                columns: new[] { "Id", "TripId", "UserId", "NumberOfTickets", "TotalPayment", "Discount", "CreatedAt", "Status", "PaymentMethod", "IsPrinted" },
                values: new object[,]
                {
                    { 1, 1, 2, 2, 300m, 0m, new DateTime(2025, 8, 11), "complete", "Stripe", false },
                    { 2, 6, 2, 1, 120m, null, new DateTime(2025, 8, 13), "accepted", "Stripe", false },
                    { 3, 3, 2, 3, 450m, 20m, new DateTime(2025, 8, 15), "canceled", "Stripe", true },
                    { 4, 4, 2, 1, 180m, null, new DateTime(2025, 8, 17), "accepted", "Stripe", false },
                    { 5, 5, 3, 2, 360m, 0m, new DateTime(2025, 8, 12), "complete", "Stripe", false },
                    { 6, 6, 3, 1, 150m, null, new DateTime(2025, 8, 14), "accepted", "Stripe", false },
                    { 7, 7, 4, 4, 600m, 30m, new DateTime(2025, 8, 16), "accepted", "Stripe", false },
                    { 8, 8, 5, 2, 300m, 0m, new DateTime(2025, 8, 18), "canceled", "Stripe", false },
                    { 9, 9, 6, 1, 200m, null, new DateTime(2025, 8, 19), "complete", "Stripe", false },
                    { 10, 10, 7, 2, 300m, 0m, new DateTime(2025, 8, 20), "accepted", "Stripe", false },
                    { 11, 11, 8, 1, 220m, null, new DateTime(2025, 8, 21), "canceled", "Stripe", false }
                });

            migrationBuilder.InsertData(
                table: "Transactions",
                columns: new[] { "Id", "PurchaseId", "Amount", "Status", "PaymentMethod", "Type", "TransactionDate", "StripeTransactionId" },
                values: new object[,]
                {
                    { 1, 1, 300m, "complete", "Stripe", "Payment", new DateTime(2025, 8, 11), "stripe_txn_0001" },
                    { 2, 2, 120m, "complete", "Stripe", "Payment", new DateTime(2025, 8, 13), "stripe_txn_0002" },
                    { 3, 3, 450m, "complete", "Stripe", "Payment", new DateTime(2025, 8, 15), "stripe_txn_0003" },
                    { 4, 3, 450m, "complete", "Stripe", "Refund", new DateTime(2025, 8, 16), "stripe_txn_0004" },
                    { 5, 4, 180m, "complete", "Stripe", "Payment", new DateTime(2025, 8, 17), "stripe_txn_0005" },
                    { 6, 5, 360m, "complete", "Stripe", "Payment", new DateTime(2025, 8, 12), "stripe_txn_0006" },
                    { 7, 6, 150m, "complete", "Stripe", "Payment", new DateTime(2025, 8, 14), "stripe_txn_0007" },
                    { 8, 7, 600m, "complete", "Stripe", "Payment", new DateTime(2025, 8, 16), "stripe_txn_0008" },
                    { 9, 8, 300m, "complete", "Stripe", "Payment", new DateTime(2025, 8, 18), "stripe_txn_0009" },
                    { 10, 8, 300m, "complete", "Stripe", "Refund", new DateTime(2025, 8, 19), "stripe_txn_0010" },
                    { 11, 9, 200m, "complete", "Stripe", "Payment", new DateTime(2025, 8, 19), "stripe_txn_0011" },
                    { 12, 10, 300m, "complete", "Stripe", "Payment", new DateTime(2025, 8, 20), "stripe_txn_0012" },
                    { 13, 11, 220m, "complete", "Stripe", "Payment", new DateTime(2025, 8, 21), "stripe_txn_0013" },
                    { 14, 11, 220m, "complete", "Stripe", "Refund", new DateTime(2025, 8, 22), "stripe_txn_0014" }
                });


            migrationBuilder.InsertData(
                table: "SupportTickets",
                columns: new[] { "Id", "UserId", "Subject", "Message", "Status", "CreatedAt", "ResolvedAt" },
                values: new object[,]
                {
                    { 1, 2, "App Crash", "App crashes when viewing trip details.", "resolved", DateTime.UtcNow.AddDays(-14), DateTime.UtcNow.AddDays(-12) },
                    { 2, 3, "Refund Request", "Requesting refund for canceled trip.", "resolved", DateTime.UtcNow.AddDays(-13), DateTime.UtcNow.AddDays(-10) },
                    { 3, 2, "Payment Issue", "Charged twice for the same trip.", "resolved", DateTime.UtcNow.AddDays(-10), DateTime.UtcNow.AddDays(-9) },
                    { 4, 3, "Profile Update", "Can't update my personal information.", "resolved", DateTime.UtcNow.AddDays(-9), DateTime.UtcNow.AddDays(-8) },
                    { 5, 2, "Invoice Request", "Need invoice for last purchase.", "resolved", DateTime.UtcNow.AddDays(-7), DateTime.UtcNow.AddDays(-6) },
                    { 6, 3, "Trip Cancellation", "Want to cancel upcoming trip.", "resolved", DateTime.UtcNow.AddDays(-6), DateTime.UtcNow.AddDays(-4) },
                    { 7, 2, "Login Problem", "Cannot log in to my account.", "open", DateTime.UtcNow.AddDays(-4), null },
                    { 8, 3, "Ticket Print", "Ticket PDF won't download or print.", "resolved", DateTime.UtcNow.AddDays(-3), DateTime.UtcNow.AddDays(-1) },
                    { 9, 2, "Refund Not Processed", "Refund for canceled trip not received.", "open", DateTime.UtcNow.AddDays(-1), null },
                    { 10, 3, "Account Deletion", "Requesting deletion of my account.", "open", DateTime.UtcNow, null },
                    { 11, 2, "Wrong Trip Dates", "Booked wrong trip dates by mistake.", "open", DateTime.UtcNow.AddDays(-2), null },
                    { 12, 3, "Trip Start Delay", "Trip started later than scheduled.", "resolved", DateTime.UtcNow.AddDays(-8), DateTime.UtcNow.AddDays(-6) },
                    { 13, 2, "Purchase Details Missing", "Cannot view details of my previous purchase.", "open", DateTime.UtcNow.AddDays(-15), null },
                    { 14, 3, "Booking Confirmation Missing", "Didn't receive email or app confirmation for my booking.", "resolved", DateTime.UtcNow.AddDays(-12), DateTime.UtcNow.AddDays(-11) },
                    { 15, 2, "Trip Bookmark Issue", "Saved trips are not showing in my bookmarks.", "open", DateTime.UtcNow.AddDays(-5), null }
                });

            migrationBuilder.InsertData(
                table: "SupportReplies",
                columns: new[] { "Id", "TicketId", "Message", "CreatedAt" },
                values: new object[,]
                {
                    { 1, 1, "We are investigating the app crash when viewing trip details.", DateTime.UtcNow.AddDays(-14) },
                    { 2, 2, "Your refund request has been approved and processed.", DateTime.UtcNow.AddDays(-10) },
                    { 3, 3, "Duplicate charge issue resolved. Refund should appear soon.", DateTime.UtcNow.AddDays(-9) },
                    { 4, 4, "Profile information updated successfully.", DateTime.UtcNow.AddDays(-8) },
                    { 5, 5, "Invoice for your last purchase has been sent to your email.", DateTime.UtcNow.AddDays(-7) },
                    { 6, 6, "Your trip cancellation has been confirmed.", DateTime.UtcNow.AddDays(-6) },
                    { 7, 8, "Ticket printing issue resolved. You should be able to download/print it now.", DateTime.UtcNow.AddDays(-3) },
                    { 8, 12, "Trip delay handled and affected customers have been notified.", DateTime.UtcNow.AddDays(-6) },
                    { 9, 14, "Booking confirmation sent via email and app notification.", DateTime.UtcNow.AddDays(-11) },
                    { 10, 9, "Refund for your canceled trip is now being processed.", DateTime.UtcNow.AddDays(-1) }
                });

            migrationBuilder.InsertData(
                table: "TripReviews",
                columns: new[] { "Id", "TripId", "UserId", "Rating", "Comment", "CreatedAt" },
                values: new object[,]
                {
                    { 1, 1, 2, 5, "Absolutely loved this trip!", DateTime.UtcNow.AddDays(-20) },
                    { 2, 1, 3, 4, "Great experience, but the hotel was a bit crowded.", DateTime.UtcNow.AddDays(-19) },
                    { 3, 1, 5, 4, "Enjoyed every moment, would travel again.", DateTime.UtcNow.AddDays(-17) },
                    { 4, 1, 6, 5, "Guides were fantastic, highly recommend!", DateTime.UtcNow.AddDays(-16) },
                    { 5, 1, 4, 4, "Nice sightseeing, enjoyed the walking tours.", DateTime.UtcNow.AddDays(-14) },
                    { 6, 2, 2, 4, "Beautiful city, very enjoyable.", DateTime.UtcNow.AddDays(-13) },
                    { 7, 2, 5, 5, "Amazing beaches and perfect weather!", DateTime.UtcNow.AddDays(-12) },
                    { 8, 2, 6, 3, "Good trip, but some activities were rushed.", DateTime.UtcNow.AddDays(-11) },
                    { 9, 2, 4, 5, "Excellent organization and staff, loved it!", DateTime.UtcNow.AddDays(-9) },
                    { 10, 2, 6, 3, "Some delays in transport, but overall a good trip.", DateTime.UtcNow.AddDays(-7) }
                });

            migrationBuilder.InsertData(
                table: "UserRecommendations",
                columns: new[] { "Id", "UserId", "TripId", "Score", "CreatedAt" },
                values: new object[,]
                {
                    { 10, 2, 4, 0.88m, DateTime.UtcNow },
                    { 11, 2, 5, 0.81m, DateTime.UtcNow },
                    { 12, 2, 6, 0.88m, DateTime.UtcNow },
                    { 13, 2, 7, 0.81m, DateTime.UtcNow },
                    { 14, 2, 8, 0.75m, DateTime.UtcNow },
                    { 15, 2, 9, 0.70m, DateTime.UtcNow },
                    { 16, 2, 10, 0.65m, DateTime.UtcNow },
                    { 17, 2, 11, 0.58m, DateTime.UtcNow },
                    { 18, 2, 12, 0.52m, DateTime.UtcNow },
                    { 19, 3, 4, 0.85m, DateTime.UtcNow },
                    { 20, 3, 5, 0.77m, DateTime.UtcNow },
                    { 21, 3, 6, 0.80m, DateTime.UtcNow },
                    { 22, 3, 7, 0.77m, DateTime.UtcNow },
                    { 23, 3, 8, 0.73m, DateTime.UtcNow },
                    { 24, 3, 9, 0.68m, DateTime.UtcNow },
                    { 25, 3, 10, 0.62m, DateTime.UtcNow },
                    { 26, 3, 11, 0.57m, DateTime.UtcNow },
                    { 27, 3, 12, 0.53m, DateTime.UtcNow }
                });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {

        }
    }
}
