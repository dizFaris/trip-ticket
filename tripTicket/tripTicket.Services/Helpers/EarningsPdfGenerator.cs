using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using tripTicket.Model.Models;

namespace tripTicket.Services.Helpers
{
    public class EarningsPdfGenerator
    {
        public static byte[] GenerateDailyReport(DateTime date, decimal total)
        {
            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Margin(40);

                    page.Header()
                        .Column(column =>
                        {
                            column.Spacing(5);

                            column.Item().Text("Trip Ticket")
                                .FontSize(32)
                                .Bold()
                                .AlignCenter();

                            column.Item().Text($"Daily Earnings Report - {date:yyyy-MM-dd}")
                                .FontSize(18)
                                .SemiBold()
                                .AlignCenter();
                        });

                    page.Content()
                        .PaddingVertical(20)
                        .Column(column =>
                        {
                            column.Item().Text("Total profit made on this day.")
                                .FontSize(14)
                                .FontColor(Colors.Grey.Darken1)
                                .AlignCenter();

                            column.Item()
                                .PaddingTop(40)
                                .AlignCenter()
                                .Text($"{total:0.00} €")
                                .FontSize(48)
                                .Bold();
                        });

                    page.Footer()
                        .AlignCenter()
                        .Text($"Report printed on {DateTime.Now:yyyy-MM-dd HH:mm}")
                        .FontSize(10)
                        .Italic()
                        .FontColor(Colors.Grey.Lighten1);
                });
            });

            return document.GeneratePdf();
        }

        public static byte[] GenerateMonthlyReport(int year, int month, EarningsReport report)
        {
            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Margin(40);

                    page.Header()
                        .Column(column =>
                        {
                            column.Spacing(5);

                            column.Item().Text("Trip Ticket")
                                .FontSize(32)
                                .Bold()
                                .AlignCenter();

                            column.Item().Text($"Monthly Earnings Report - {month:D2}/{year}")
                                .FontSize(18)
                                .SemiBold()
                                .AlignCenter();
                        });

                    page.Content()
                        .PaddingVertical(20)
                        .Column(column =>
                        {
                            column.Spacing(15);

                            column.Item().Text("Total earnings per day for selected month")
                                .FontSize(14)
                                .FontColor(Colors.Grey.Darken1)
                                .AlignCenter();

                            column.Item().Table(table =>
                            {
                                table.ColumnsDefinition(columns =>
                                {
                                    columns.RelativeColumn(1);
                                    columns.RelativeColumn(2);
                                });

                                table.Header(header =>
                                {
                                    header.Cell().Text("Day").Bold();
                                    header.Cell().Text("Earnings (€)").Bold();
                                });

                                foreach (var entry in report.Data)
                                {
                                    table.Cell().Text(entry.Label).FontSize(12);
                                    table.Cell().Text(entry.Value.ToString("0.00")).FontSize(12);
                                }
                            });

                            column.Item()
                                .PaddingTop(10)
                                .AlignRight()
                                .Text($"Total Earnings: {report.Total:0.00} €")
                                .FontSize(16)
                                .Bold();
                        });

                    page.Footer()
                        .AlignCenter()
                        .Text($"Report printed on {DateTime.Now:yyyy-MM-dd HH:mm}")
                        .FontSize(10)
                        .Italic()
                        .FontColor(Colors.Grey.Lighten1);
                });
            });

            return document.GeneratePdf();
        }

        public static byte[] GenerateYearlyReport(int year, EarningsReport report)
        {
            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Margin(40);

                    page.Header()
                        .Column(column =>
                        {
                            column.Spacing(5);

                            column.Item().Text("Trip Ticket")
                                .FontSize(32)
                                .Bold()
                                .AlignCenter();

                            column.Item().Text($"Yearly Earnings Report - {year}")
                                .FontSize(18)
                                .SemiBold()
                                .AlignCenter();
                        });

                    page.Content()
                        .PaddingVertical(20)
                        .Column(column =>
                        {
                            column.Spacing(15);

                            column.Item().Text("Total earnings per month for selected year")
                                .FontSize(14)
                                .FontColor(Colors.Grey.Darken1)
                                .AlignCenter();

                            column.Item().Table(table =>
                            {
                                table.ColumnsDefinition(columns =>
                                {
                                    columns.RelativeColumn(2);
                                    columns.RelativeColumn(1);
                                });

                                table.Header(header =>
                                {
                                    header.Cell().Text("Month").Bold();
                                    header.Cell().Text("Earnings (€)").Bold();
                                });

                                foreach (var entry in report.Data)
                                {
                                    table.Cell().Text(entry.Label).FontSize(12);
                                    table.Cell().Text(entry.Value.ToString("0.00")).FontSize(12);
                                }
                            });

                            column.Item()
                                .PaddingTop(10)
                                .AlignRight()
                                .Text($"Total Earnings: {report.Total:0.00} €")
                                .FontSize(16)
                                .Bold();
                        });

                    page.Footer()
                        .AlignCenter()
                        .Text($"Report printed on {DateTime.Now:yyyy-MM-dd HH:mm}")
                        .FontSize(10)
                        .Italic()
                        .FontColor(Colors.Grey.Lighten1);
                });
            });

            return document.GeneratePdf();
        }

    }
}
