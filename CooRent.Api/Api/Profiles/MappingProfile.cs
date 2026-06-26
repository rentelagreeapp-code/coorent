using AutoMapper;
using CooRent.Api.Core.Entities;
using CooRent.Api.Core.DTOs;

namespace CooRent.Api.Api.Profiles
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<User, UserDto>();
            CreateMap<UserDto, User>();
        }
    }
}
