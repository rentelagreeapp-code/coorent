using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using CooRent.Api.Core.DTOs;
using CooRent.Api.Core.Entities;
using CooRent.Api.Core.Interfaces;

namespace CooRent.Api.Infrastructure.Services
{
    public class UserService : IUserService
    {
        private readonly IUserRepository _userRepository;
        private readonly IRefreshTokenRepository _refreshTokenRepository;
        private readonly IConfiguration _configuration;

        public UserService(
            IUserRepository userRepository,
            IRefreshTokenRepository refreshTokenRepository,
            IConfiguration configuration)
        {
            _userRepository = userRepository;
            _refreshTokenRepository = refreshTokenRepository;
            _configuration = configuration;
        }

        public async Task<AuthResponseDto> RegisterAsync(RegisterUserRequestDto request, string ipAddress)
        {
            var existingUser = await _userRepository.GetByMobileNumberAsync(request.MobileNumber);
            if (existingUser != null)
            {
                throw new Exception("User already registered with this mobile number");
            }

            var user = new User
            {
                Name = request.Name,
                MobileNumber = request.MobileNumber,
                IsActive = true
            };

            await _userRepository.AddAsync(user);

            var (accessToken, accessTokenExpiry) = GenerateJwtToken(user);
            var refreshToken = await GenerateAndSaveRefreshToken(user.Id, request.DeviceId, request.DeviceName, ipAddress);

            return new AuthResponseDto
            {
                IsNewUser = false,
                AccessToken = accessToken,
                RefreshToken = refreshToken.Token,
                AccessTokenExpiry = accessTokenExpiry,
                User = new UserDto
                {
                    Id = user.Id,
                    Name = user.Name,
                    MobileNumber = user.MobileNumber,
                    IsActive = user.IsActive
                }
            };
        }

        public async Task<UserDto> GetProfileAsync(Guid userId)
        {
            var user = await _userRepository.GetByIdAsync(userId);
            if (user == null)
            {
                throw new Exception("User not found");
            }

            return new UserDto
            {
                Id = user.Id,
                Name = user.Name,
                MobileNumber = user.MobileNumber,
                IsActive = user.IsActive
            };
        }

        public async Task<UserDto> UpdateProfileAsync(Guid userId, UpdateUserRequestDto request)
        {
            var user = await _userRepository.GetByIdAsync(userId);
            if (user == null)
            {
                throw new Exception("User not found");
            }

            user.Name = request.Name;
            await _userRepository.UpdateAsync(user);

            return new UserDto
            {
                Id = user.Id,
                Name = user.Name,
                MobileNumber = user.MobileNumber,
                IsActive = user.IsActive
            };
        }

        private (string token, DateTime expiry) GenerateJwtToken(User user)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var keyStr = _configuration["Jwt:Key"] ?? "super_secret_coorent_key_long_enough_to_meet_requirements_2026_06_26";
            var key = Encoding.ASCII.GetBytes(keyStr);

            var expiry = DateTime.UtcNow.AddMinutes(15);
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
                    new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                    new Claim(ClaimTypes.MobilePhone, user.MobileNumber),
                    new Claim(ClaimTypes.Name, user.Name)
                }),
                Expires = expiry,
                Issuer = _configuration["Jwt:Issuer"] ?? "CooRent",
                Audience = _configuration["Jwt:Audience"] ?? "CooRentMobile",
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return (tokenHandler.WriteToken(token), expiry);
        }

        private async Task<RefreshToken> GenerateAndSaveRefreshToken(Guid userId, string deviceId, string deviceName, string ipAddress)
        {
            var activeToken = await _refreshTokenRepository.GetActiveTokenForDeviceAsync(userId, deviceId);
            if (activeToken != null)
            {
                activeToken.IsRevoked = true;
                activeToken.RevokedDate = DateTime.UtcNow;
                activeToken.RevokedByIp = ipAddress;
                await _refreshTokenRepository.UpdateAsync(activeToken);
            }

            var refreshToken = new RefreshToken
            {
                UserId = userId,
                Token = GenerateRefreshTokenString(),
                ExpiryDate = DateTime.UtcNow.AddDays(30),
                CreatedByIp = ipAddress,
                DeviceId = deviceId,
                DeviceName = deviceName
            };

            await _refreshTokenRepository.AddAsync(refreshToken);
            return refreshToken;
        }

        private string GenerateRefreshTokenString()
        {
            var randomNumber = new byte[64];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber);
            return Convert.ToBase64String(randomNumber);
        }
    }
}
