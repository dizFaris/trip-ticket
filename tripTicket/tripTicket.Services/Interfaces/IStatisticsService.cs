using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Models;

namespace tripTicket.Services.Interfaces
{
    public interface IStatisticsService
    {
        Task<decimal> GetDailyEarningsAsync(DateTime date);
        Task<EarningsReport> GetMonthlyEarningsAsync(int year, int month);
        Task<EarningsReport> GetYearlyEarningsAsync(int year);
        Task<byte[]> GenerateDailyEarningsPdfAsync(DateTime date);
        Task<byte[]> GenerateMonthlyEarningsPdfAsync(int year, int month);
        Task<byte[]> GenerateYearlyEarningsPdfAsync(int year);
    }
}
