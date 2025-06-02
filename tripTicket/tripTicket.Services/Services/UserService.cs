using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;
using tripTicket.Model.Models;
using tripTicket.Model.Requests;
using tripTicket.Model.SearchObjects;
using tripTicket.Services.Database;
using tripTicket.Services.Helpers;
using tripTicket.Services.Interfaces;
using tripTicket.Services.TripStateMachine;

namespace tripTicket.Services.Services
{
    public class UserService : BaseCRUDService<Model.Models.User, UserSearchObject, Database.User, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        public UserService(TripTicketDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Database.User> AddFilter(UserSearchObject search, IQueryable<Database.User> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search?.FTS))
            {
                filteredQuery = filteredQuery.Where(x =>
                    x.FirstName.Contains(search.FTS) ||
                    x.LastName.Contains(search.FTS) ||
                    x.Username.Contains(search.FTS) ||
                    x.Email.Contains(search.FTS));
            }

            if (search.BirthDate != null)
            {
                filteredQuery = filteredQuery.Where(x => x.BirthDate == search.BirthDate);
            }

            return filteredQuery;
        }

        public override void BeforeInsert(UserInsertRequest request, Database.User entity)
        {
            if (Context.Users.Any(u => u.Username == request.Username))
            {
                throw new UserException("Username taken");
            }

            if (Context.Users.Any(u => u.Email == request.Email))
            {
                throw new UserException("Email already used");
            }

            var pwValidationResult = ValidationHelpers.CheckPasswordStrength(request.Password);
            if (!string.IsNullOrEmpty(pwValidationResult))
            {
                throw new UserException("Invalid password");
            }

            if (!string.IsNullOrEmpty(request.Phone))
            {
                var phoneValidationResult = ValidationHelpers.CheckPhoneNumber(request.Phone);
                if (!string.IsNullOrEmpty(phoneValidationResult))
                {
                    throw new UserException("Invalid phone number");
                }
            }

            if (request.Password != request.PasswordConfirm)
            {
                throw new UserException("Password and confirm password are not matching");
            }

            entity.PasswordSalt = HashGenerator.GenerateSalt();
            entity.PasswordHash = HashGenerator.GenerateHash(entity.PasswordSalt, request.Password);

            var defaultRole = Context.Roles.FirstOrDefault(r => r.Name == "User");
            if (defaultRole == null)
            {
                throw new Exception("Default 'User' role not found in the database.");
            }

            entity.UserRoles = new List<Database.UserRole>
            {
                new Database.UserRole
                {
                    RoleId = defaultRole.Id
                }
            };
        }

        public override void BeforeUpdate(UserUpdateRequest request, Database.User entity)
        {
            base.BeforeUpdate(request, entity);
            if (!string.IsNullOrEmpty(request.Password))
            {
                var pw = ValidationHelpers.CheckPasswordStrength(request.Password);
                if (!string.IsNullOrEmpty(pw))
                {
                    throw new UserException("Invalid password");
                }
            }
            if (!string.IsNullOrEmpty(request.Phone))
            {
                var phoneNumber = ValidationHelpers.CheckPhoneNumber(request.Phone);
                if (!string.IsNullOrEmpty(phoneNumber))
                {
                    throw new UserException("Invalid phone number");
                }
            }
            if (request.Password != null)
            {
                if (request.Password != request.PasswordConfirm)
                {
                    throw new UserException("Password and confirm password are not matching");
                }
                entity!.PasswordSalt = HashGenerator.GenerateSalt();
                entity.PasswordHash = HashGenerator.GenerateHash(entity.PasswordSalt, request.Password);
            }
        }

        public async Task<List<Model.Models.Role>> GetUserRolesAsync(int id)
        {
            var roles = await Context.UserRoles
                .Where(ur => ur.UserId == id)
                .Select(ur => ur.Role)
                .ToListAsync();

            return Mapper.Map<List<Model.Models.Role>>(roles);
        }

        public Model.Models.User Login(string username, string password)
        {
            if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
            {
                throw new UserException("Username and password are required");
            }

            var entity = Context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(r => r.Role)
                .FirstOrDefault(x => x.Username == username);

            if (entity == null)
            {
                throw new UserException("User not found");
            }

            var hash = HashGenerator.GenerateHash(entity.PasswordSalt, password);

            if (hash != entity.PasswordHash)
            {
                throw new UserException("Invalid username or password");
            }

            return Mapper.Map<Model.Models.User>(entity);
        }
    }
}
