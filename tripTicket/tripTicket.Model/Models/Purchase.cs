using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Transactions;

namespace tripTicket.Model.Models
{
    public class Purchase
    {
        public int Id { get; set; }
        public int TripId { get; set; }
        public TripShort Trip { get; set; } = null!;
        public int UserId { get; set; }
        public UserShort User { get; set; } = null!;
        public int NumberOfTickets { get; set; }
        public decimal TotalPayment { get; set; }
        public decimal? Discount { get; set; }
        public DateTime CreatedAt { get; set; }
        public string Status { get; set; } = null!;
        public string PaymentMethod { get; set; } = null!;
        public bool IsPrinted { get; set; }

    }
    public class TripShort
    {
        public int Id { get; set; }
        public byte[]? Photo { get; set; }
        public string City { get; set; } = null!;
        public string Country { get; set; } = null!;
        public string CountryCode {  get; set; } = null!;
        public DateOnly ExpirationDate { get; set; }
        public DateOnly? FreeCancellationUntil { get; set; }
        public decimal? CancellationFee { get; set; }
    }

    public class UserShort
    {
        public string FirstName { get; set; } = null!;
        public string LastName { get; set; } = null!;
        public string Username { get; set; } = null!;
    }
}
