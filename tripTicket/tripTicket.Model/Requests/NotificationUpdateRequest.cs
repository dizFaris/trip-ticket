﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Models;

namespace tripTicket.Model.Requests
{
    public class NotificationUpdateRequest
    {
        public int Id { get; set; }
        public string Message { get; set; } = null!;
    }
}
