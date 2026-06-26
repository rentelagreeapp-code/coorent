using System.Threading.Tasks;
using CooRent.Api.Core.DTOs;

namespace CooRent.Api.Core.Interfaces
{
    public interface IAuthService
    {
        Task<SendOtpResponseDto> SendOtpAsync(SendOtpRequestDto request);
        Task<AuthResponseDto> VerifyOtpAsync(VerifyOtpRequestDto request, string ipAddress);
        Task<AuthResponseDto> RefreshTokenAsync(RefreshTokenRequestDto request, string ipAddress);
        Task<bool> LogoutAsync(LogoutRequestDto request, string ipAddress);
    }

    public interface IUserService
    {
        Task<AuthResponseDto> RegisterAsync(RegisterUserRequestDto request, string ipAddress);
        Task<UserDto> GetProfileAsync(Guid userId);
        Task<UserDto> UpdateProfileAsync(Guid userId, UpdateUserRequestDto request);
    }
}
