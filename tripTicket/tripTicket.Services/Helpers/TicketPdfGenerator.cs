using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using System;

namespace tripTicket.Services.Helpers
{
    public class TicketPdfGenerator
    {
        public static byte[] GenerateTickets(Model.Models.Purchase purchase)
        {
            var pricePerTicket = purchase.TotalPayment / purchase.NumberOfTickets;

            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Margin(30);
                    page.Size(PageSizes.A4);

                    page.Content().Column(column =>
                    {
                        column.Spacing(4);
                        for (int i = 1; i <= purchase.NumberOfTickets; i++)
                        {
                            column.Item().Border(1).Padding(10).Element(ticket =>
                            {
                                ticket.Column(col =>
                                {
                                    col.Spacing(4);

                                    col.Item().Row(row =>
                                    {
                                        row.RelativeItem(3).Column(inner =>
                                        {
                                            inner.Item().Text("Trip Ticket").FontSize(14).Bold();
                                            inner.Item().Text($"Passenger: {purchase.User.FirstName} {purchase.User.LastName}").FontSize(10);
                                            inner.Item().Text($"Username: {purchase.User.Username}").FontSize(10);
                                            inner.Item().Text($"Purchase ID #: {purchase.Id}").FontSize(10);
                                        });

                                        row.RelativeItem(4).Column(inner =>
                                        {
                                            inner.Item().Text($"To: {purchase.Trip.City}, {purchase.Trip.Country} ({purchase.Trip.CountryCode})").FontSize(10);
                                            inner.Item().Text($"Valid Until: {purchase.Trip.ExpirationDate:yyyy-MM-dd}").FontSize(10);
                                            inner.Item().Text($"Payment Method: {purchase.PaymentMethod}").FontSize(10);
                                            inner.Item().Text($"Issued: {purchase.CreatedAt:yyyy-MM-dd HH:mm}").FontSize(9).Italic();
                                        });

                                        row.RelativeItem(2).AlignRight().Column(inner =>
                                        {
                                            inner.Item().Text($"{pricePerTicket:0.00} €").FontSize(14).Bold();

                                            if (purchase.Discount.HasValue && purchase.Discount.Value > 0)
                                            {
                                                inner.Item().Text($"Discount: {purchase.Discount.Value:0.00} €")
                                                    .FontColor(Colors.Red.Medium)
                                                    .FontSize(10);
                                            }

                                            inner.Item().Text($"Ticket #: {i}/{purchase.NumberOfTickets}").FontSize(10);
                                        });
                                    });
                                });
                            });

                            if (i % 5 == 0 && i != purchase.NumberOfTickets)
                            {
                                column.Item().PageBreak();
                            }
                        }
                    });
                });
            });

            return document.GeneratePdf();
        }
    }
}
