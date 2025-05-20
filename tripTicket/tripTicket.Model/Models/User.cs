using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tripTicket.Model.Models
{
    public class User
    {
        public int Id { get; set; }

        public string FirstName { get; set; } = null!;

        public string LastName { get; set; } = null!;

        public string Email { get; set; } = null!;

        public string? Phone { get; set; }

        public DateOnly BirthDate { get; set; }

        public bool IsDeleted { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
