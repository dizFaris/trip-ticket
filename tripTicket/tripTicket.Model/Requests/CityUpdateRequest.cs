﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Models;

namespace tripTicket.Model.Requests
{
    public class CityUpdateRequest
    {
        public string? Name { get; set; }
        public bool? IsActive {  get; set; }
    }
}
