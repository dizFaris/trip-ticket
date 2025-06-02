using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Models;

namespace tripTicket.Model.Response
{
    public class UserInsertResponse
    {
        public int Id { get; set; }

        public string FirstName { get; set; } = null!;

        public string LastName { get; set; } = null!;
        public string Username { get; set; } = null!;

        public string Email { get; set; } = null!;

        public string? Phone { get; set; }

        public DateOnly BirthDate { get; set; }

        public bool IsDeleted { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
