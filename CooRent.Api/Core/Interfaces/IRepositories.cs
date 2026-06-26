using System;
using System.Threading.Tasks;
using CooRent.Api.Core.Entities;

namespace CooRent.Api.Core.Interfaces
{
    public interface IUserRepository
    {
        Task<User?> GetByIdAsync(Guid id);
        Task<User?> GetByMobileNumberAsync(string mobileNumber);
        Task AddAsync(User user);
        Task UpdateAsync(User user);
    }

    public interface IOtpRepository
    {
        Task AddAsync(Otp otp);
        Task<Otp?> GetLatestOtpAsync(string mobileNumber);
        Task UpdateAsync(Otp otp);
    }

    public interface IRefreshTokenRepository
    {
        Task AddAsync(RefreshToken token);
        Task<RefreshToken?> GetByTokenAsync(string token);
        Task<RefreshToken?> GetActiveTokenForDeviceAsync(Guid userId, string deviceId);
        Task UpdateAsync(RefreshToken token);
    }
}
