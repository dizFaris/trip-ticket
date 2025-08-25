﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tripTicket.Model.Requests
{
    public class UserInsertRequest
    {
        public string FirstName { get; set; } = null!;

        public string LastName { get; set; } = null!;
        public string Username { get; set; } = null!;

        public string Email { get; set; } = null!;

        public string Phone { get; set; }

        public string Password { get; set; }

        public string PasswordConfirm { get; set; }

        public DateOnly BirthDate { get; set; }
        public string Role { get; set; } = "User";
    }
}
