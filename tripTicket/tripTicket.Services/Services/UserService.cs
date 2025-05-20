using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using tripTicket.Model;
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
            var pwValidationResult = ValidationHelpers.CheckPasswordStrength(request.Password);
            if (!string.IsNullOrEmpty(pwValidationResult))
            {
                throw new Exception("Invalid password");
            }

            if (!string.IsNullOrEmpty(request.Phone))
            {
                var phoneValidationResult = ValidationHelpers.CheckPhoneNumber(request.Phone);
                if (!string.IsNullOrEmpty(phoneValidationResult))
                {
                    throw new Exception("Invalid phone number");
                }
            }

            if (request.Password != request.PasswordConfirm)
            {
                throw new Exception("Password and confirm password are not matching");
            }

            entity.PasswordSalt = HashGenerator.GenerateSalt();
            entity.PasswordHash = HashGenerator.GenerateHash(entity.PasswordSalt, request.Password);

            base.BeforeInsert(request, entity);
        }

        public override void BeforeUpdate(UserUpdateRequest request, Database.User entity)
        {
            base.BeforeUpdate(request, entity);
            if (!string.IsNullOrEmpty(request.Password))
            {
                var pw = ValidationHelpers.CheckPasswordStrength(request.Password);
                if (!string.IsNullOrEmpty(pw))
                {
                    throw new Exception("Invalid password");
                }
            }
            if (!string.IsNullOrEmpty(request.Phone))
            {
                var phoneNumber = ValidationHelpers.CheckPhoneNumber(request.Phone);
                if (!string.IsNullOrEmpty(phoneNumber))
                {
                    throw new Exception("Invalid phone number");
                }
            }
            if (request.Password != null)
            {
                if (request.Password != request.PasswordConfirm)
                {
                    throw new Exception("Password and confirm password are not matching");
                }
                entity!.PasswordSalt = HashGenerator.GenerateSalt();
                entity.PasswordHash = HashGenerator.GenerateHash(entity.PasswordSalt, request.Password);
            }
        }
    }
}
