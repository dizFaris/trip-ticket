using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Models;
using tripTicket.Services.Database;
using tripTicket.Services.Helpers;
using tripTicket.Services.Interfaces;

namespace tripTicket.Services.Services
{
    public class StatisticsService : IStatisticsService
    {
        private readonly TripTicketDbContext Context;
        public StatisticsService(TripTicketDbContext context)
        {
            Context = context;
        }

        public async Task<decimal> GetDailyEarningsAsync(DateTime date)
        {
            var total = await Context.Purchases
                .Where(p => p.Status == "complete" && p.CreatedAt.Date == date.Date)
                .SumAsync(p => p.TotalPayment);

            return total;
        }

        public async Task<EarningsReport> GetMonthlyEarningsAsync(int year, int month)
        {
            var start = new DateTime(year, month, 1);
            var end = start.AddMonths(1);

            var query = await Context.Purchases
                .Where(p => p.Status == "complete" && p.CreatedAt >= start && p.CreatedAt < end)
                .GroupBy(p => p.CreatedAt.Date)
                .Select(g => new
                {
                    Date = g.Key,
                    Total = g.Sum(p => p.TotalPayment)
                })
                .OrderBy(x => x.Date)
                .ToListAsync();

            var report = new EarningsReport
            {
                Total = query.Sum(x => x.Total),
                Data = query.Select(x => new EarningsEntry
                {
                    Label = x.Date.Day.ToString(),
                    Value = x.Total
                }).ToList()
            };

            return report;
        }

        public async Task<EarningsReport> GetYearlyEarningsAsync(int year)
        {
            var start = new DateTime(year, 1, 1);
            var end = start.AddYears(1);

            var query = await Context.Purchases
                .Where(p => p.Status == "complete" && p.CreatedAt >= start && p.CreatedAt < end)
                .GroupBy(p => new { p.CreatedAt.Year, p.CreatedAt.Month })
                .Select(g => new
                {
                    Year = g.Key.Year,
                    Month = g.Key.Month,
                    Total = g.Sum(p => p.TotalPayment)
                })
                .OrderBy(x => x.Month)
                .ToListAsync();

            var report = new EarningsReport
            {
                Total = query.Sum(x => x.Total),
                Data = query.Select(x => new EarningsEntry
                {
                    Label = new DateTime(x.Year, x.Month, 1).ToString("MMM"),
                    Value = x.Total
                }).ToList()
            };

            return report;
        }

        public async Task<byte[]> GenerateMonthlyEarningsPdfAsync(int year, int month)
        {
            var report = await GetMonthlyEarningsAsync(year, month);
            return EarningsPdfGenerator.GenerateMonthlyReport(year, month, report);
        }

        public async Task<byte[]> GenerateDailyEarningsPdfAsync(DateTime date)
        {
            var start = date.Date;
            var end = start.AddDays(1);

            var total = await Context.Purchases
                .Where(p => p.Status == "complete" && p.CreatedAt >= start && p.CreatedAt < end)
                .SumAsync(p => (decimal?)p.TotalPayment) ?? 0m;

            return EarningsPdfGenerator.GenerateDailyReport(date, total);
        }

        public async Task<byte[]> GenerateYearlyEarningsPdfAsync(int year)
        {
            var start = new DateTime(year, 1, 1);
            var end = start.AddYears(1);

            var query = await Context.Purchases
                .Where(p => p.Status == "complete" && p.CreatedAt >= start && p.CreatedAt < end)
                .GroupBy(p => p.CreatedAt.Month)
                .Select(g => new
                {
                    Month = g.Key,
                    Total = g.Sum(p => p.TotalPayment)
                })
                .OrderBy(x => x.Month)
                .ToListAsync();

            var monthNames = System.Globalization.CultureInfo.CurrentCulture.DateTimeFormat.AbbreviatedMonthNames;

            var report = new EarningsReport
            {
                Total = query.Sum(x => x.Total),
                Data = query.Select(x => new EarningsEntry
                {
                    Label = monthNames[x.Month - 1],
                    Value = x.Total
                }).ToList()
            };

            return EarningsPdfGenerator.GenerateYearlyReport(year, report);
        }

    }
}
