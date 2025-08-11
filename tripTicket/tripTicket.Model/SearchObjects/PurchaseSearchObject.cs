using System;

namespace tripTicket.Model.SearchObjects
{
    public class PurchaseSearchObject : BaseSearchObject
    {
        public string? FTS { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
        public int? MinTicketCount { get; set; }
        public int? MaxTicketCount { get; set; }
        public decimal? MinPayment { get; set; }
        public decimal? MaxPayment { get; set; }
        public string? Status { get; set; }
        public int? UserId { get; set; }

    }
}
