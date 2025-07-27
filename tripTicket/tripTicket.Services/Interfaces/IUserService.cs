using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;

namespace tripTicket.Services.Interfaces
{
    public interface IUserService : ICRUDService<User, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        Task<List<Role>> GetUserRolesAsync(int id);
        User Login(string username, string password);
        User ToggleActiveStatus(int userId, UserToggleActiveRequest request);
    }
}
