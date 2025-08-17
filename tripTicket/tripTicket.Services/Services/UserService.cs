﻿using MapsterMapper;
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

            filteredQuery = filteredQuery.Where(x =>
                !x.UserRoles.Any(ur => ur.Role.Name == "Admin")
            );

            if (search.FromDate.HasValue)
            {
                filteredQuery = filteredQuery.Where(x => x.BirthDate >= search.FromDate.Value);
            }

            if (search.ToDate.HasValue)
            {
                filteredQuery = filteredQuery.Where(x => x.BirthDate <= search.ToDate.Value);
            }

            if (search.IsActive.HasValue)
            {
                filteredQuery = filteredQuery.Where(x => x.IsActive == search.IsActive.Value);
            }

            filteredQuery = filteredQuery.OrderByDescending(p => p.CreatedAt);

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
            entity.IsActive = true;

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

            if (entity == null)
                throw new UserException("User entity not found.");

            if (!entity.IsActive)
                throw new UserException("Cannot update data of an inactive user.");

            if (!string.IsNullOrWhiteSpace(request.Phone))
            {
                var phoneError = ValidationHelpers.CheckPhoneNumber(request.Phone);
                if (!string.IsNullOrEmpty(phoneError))
                    throw new UserException("Invalid phone number");
            }

            if (!string.IsNullOrWhiteSpace(request.NewPassword))
            {
                if (string.IsNullOrWhiteSpace(request.CurrentPassword))
                    throw new UserException("Current password is required to change your password.");

                var isCurrentPasswordValid = entity.PasswordHash ==
                    HashGenerator.GenerateHash(entity.PasswordSalt, request.CurrentPassword);

                if (!isCurrentPasswordValid)
                    throw new UserException("Current password is incorrect.");

                var pwError = ValidationHelpers.CheckPasswordStrength(request.NewPassword);
                if (!string.IsNullOrEmpty(pwError))
                    throw new UserException("Invalid password");

                if (request.NewPassword != request.NewPasswordConfirm)
                    throw new UserException("New password and confirmation do not match.");

                entity.PasswordSalt = HashGenerator.GenerateSalt();
                entity.PasswordHash = HashGenerator.GenerateHash(entity.PasswordSalt, request.NewPassword);
            }

            if (!string.IsNullOrWhiteSpace(request.FirstName))
                entity.FirstName = request.FirstName;

            if (!string.IsNullOrWhiteSpace(request.LastName))
                entity.LastName = request.LastName;

            if (!string.IsNullOrWhiteSpace(request.Username))
                entity.Username = request.Username;

            if (!string.IsNullOrWhiteSpace(request.Email))
                entity.Email = request.Email;

            if (!string.IsNullOrWhiteSpace(request.Phone))
                entity.Phone = request.Phone;

            if (request.BirthDate.HasValue)
                entity.BirthDate = request.BirthDate.Value;
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

            if (!entity.IsActive)
            {
                throw new UserException("Your account has been deactivated. Please contact the administrator for help.");
            }

            var hash = HashGenerator.GenerateHash(entity.PasswordSalt, password);

            if (hash != entity.PasswordHash)
            {
                throw new UserException("Invalid username or password");
            }

            return Mapper.Map<Model.Models.User>(entity);
        }


        public Model.Models.User ToggleActiveStatus(int userId, UserToggleActiveRequest request)
        {
            var user = Context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .FirstOrDefault(u => u.Id == userId);

            if (user == null)
                throw new UserException("User not found.");

            bool isAdmin = user.UserRoles.Any(ur => ur.Role.Name == "Admin");

            if (!request.IsActive && isAdmin)
                throw new UserException("Cannot deactivate a user with the Admin role.");

            user.IsActive = request.IsActive;
            Context.SaveChanges();

            return Mapper.Map<Model.Models.User>(user);
        }
    }
}
