using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using tripTicket.Services.Interfaces;

namespace tripTicket.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class StatisticsController : ControllerBase
    {
        private readonly IStatisticsService _statisticsService;
        public StatisticsController(IStatisticsService statisticsService)
        {
            _statisticsService = statisticsService;
        }

        [HttpGet("earnings/daily")]
        public async Task<IActionResult> GetDailyEarnings([FromQuery] DateTime date)
        {
            var total = await _statisticsService.GetDailyEarningsAsync(date);
            return Ok(new { total });
        }

        [HttpGet("earnings/monthly")]
        public async Task<IActionResult> GetMonthlyEarnings([FromQuery] int year, [FromQuery] int month)
        {
            var report = await _statisticsService.GetMonthlyEarningsAsync(year, month);
            return Ok(report);
        }

        [HttpGet("earnings/yearly")]
        public async Task<IActionResult> GetYearlyEarnings([FromQuery] int year)
        {
            var report = await _statisticsService.GetYearlyEarningsAsync(year);
            return Ok(report);
        }

        [HttpGet("earnings/daily/pdf")]
        public async Task<IActionResult> GetDailyEarningsPdf([FromQuery] DateTime date)
        {
            var pdfBytes = await _statisticsService.GenerateDailyEarningsPdfAsync(date);
            var fileName = $"Daily-Earnings-{date:yyyy-MM-dd}.pdf";
            return File(pdfBytes, "application/pdf", fileName);
        }

        [HttpGet("earnings/monthly/pdf")]
        public async Task<IActionResult> GetMonthlyEarningsPdf([FromQuery] int year, [FromQuery] int month)
        {
            try
            {
                var pdfBytes = await _statisticsService.GenerateMonthlyEarningsPdfAsync(year, month);
                var fileName = $"Monthly-Earnings-{year}-{month:D2}.pdf";
                return File(pdfBytes, "application/pdf", fileName);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error: {ex.Message}");
            }
        }

        [HttpGet("earnings/yearly/pdf")]
        public async Task<IActionResult> GetYearlyEarningsPdf([FromQuery] int year)
        {
            var pdfBytes = await _statisticsService.GenerateYearlyEarningsPdfAsync(year);
            var fileName = $"Yearly-Earnings-{year}.pdf";
            return File(pdfBytes, "application/pdf", fileName);
        }
    }
}
