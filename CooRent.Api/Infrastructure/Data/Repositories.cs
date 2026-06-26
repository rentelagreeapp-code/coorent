using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using CooRent.Api.Core.Entities;
using CooRent.Api.Core.Interfaces;

namespace CooRent.Api.Infrastructure.Data
{
    public class UserRepository : IUserRepository
    {
        private readonly ApplicationDbContext _context;

        public UserRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<User?> GetByIdAsync(Guid id)
        {
            return await _context.Users.FindAsync(id);
        }

        public async Task<User?> GetByMobileNumberAsync(string mobileNumber)
        {
            return await _context.Users.FirstOrDefaultAsync(u => u.MobileNumber == mobileNumber);
        }

        public async Task AddAsync(User user)
        {
            await _context.Users.AddAsync(user);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(User user)
        {
            user.UpdatedDate = DateTime.UtcNow;
            _context.Users.Update(user);
            await _context.SaveChangesAsync();
        }
    }

    public class OtpRepository : IOtpRepository
    {
        private readonly ApplicationDbContext _context;

        public OtpRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task AddAsync(Otp otp)
        {
            await _context.Otps.AddAsync(otp);
            await _context.SaveChangesAsync();
        }

        public async Task<Otp?> GetLatestOtpAsync(string mobileNumber)
        {
            return await _context.Otps
                .Where(o => o.MobileNumber == mobileNumber)
                .OrderByDescending(o => o.CreatedDate)
                .FirstOrDefaultAsync();
        }

        public async Task UpdateAsync(Otp otp)
        {
            _context.Otps.Update(otp);
            await _context.SaveChangesAsync();
        }
    }

    public class RefreshTokenRepository : IRefreshTokenRepository
    {
        private readonly ApplicationDbContext _context;

        public RefreshTokenRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task AddAsync(RefreshToken token)
        {
            await _context.RefreshTokens.AddAsync(token);
            await _context.SaveChangesAsync();
        }

        public async Task<RefreshToken?> GetByTokenAsync(string token)
        {
            return await _context.RefreshTokens.FirstOrDefaultAsync(t => t.Token == token);
        }

        public async Task<RefreshToken?> GetActiveTokenForDeviceAsync(Guid userId, string deviceId)
        {
            return await _context.RefreshTokens
                .FirstOrDefaultAsync(t => t.UserId == userId && t.DeviceId == deviceId && !t.IsRevoked && t.ExpiryDate > DateTime.UtcNow);
        }

        public async Task UpdateAsync(RefreshToken token)
        {
            _context.RefreshTokens.Update(token);
            await _context.SaveChangesAsync();
        }
    }
}
