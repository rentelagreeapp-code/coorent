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
using Twilio.Rest.Api.V2010.Account;
using CooRent.Api.Core.Interfaces;

namespace CooRent.Api.Infrastructure.Services
{
    public class AuthService : IAuthService
    {
        private readonly IUserRepository _userRepository;
        private readonly IOtpRepository _otpRepository;
        private readonly IRefreshTokenRepository _refreshTokenRepository;
        private readonly IConfiguration _configuration;

        public AuthService(
            IUserRepository userRepository,
            IOtpRepository otpRepository,
            IRefreshTokenRepository refreshTokenRepository,
            IConfiguration configuration)
        {
            _userRepository = userRepository;
            _otpRepository = otpRepository;
            _refreshTokenRepository = refreshTokenRepository;
            _configuration = configuration;
        }

        public async Task<SendOtpResponseDto> SendOtpAsync(SendOtpRequestDto request)
        {
            // Simple 6 digit OTP generation
            var random = new Random();
            var otpCode = random.Next(100000, 999999).ToString();

            var otp = new Otp
            {
                MobileNumber = request.MobileNumber,
                OtpCode = otpCode,
                ExpiresAt = DateTime.UtcNow.AddMinutes(5),
                IsVerified = false
            };

            await _otpRepository.AddAsync(otp);

            // Integrate Twilio WhatsApp Send
            var twilioSid = _configuration["Twilio:AccountSid"];
            var twilioToken = _configuration["Twilio:AuthToken"];
            var twilioFrom = _configuration["Twilio:WhatsAppFromNumber"] ?? "+14155238886"; // Default Twilio Sandbox Number

            if (!string.IsNullOrEmpty(twilioSid) && !string.IsNullOrEmpty(twilioToken))
            {
                try
                {
                    Twilio.TwilioClient.Init(twilioSid, twilioToken);
                    
                    // Render/standardize phone number format for WhatsApp (e.g. +91XXXXXXXXXX)
                    var formattedNumber = request.MobileNumber.StartsWith("+") ? request.MobileNumber : $"+91{request.MobileNumber}";

                    var messageOptions = new CreateMessageOptions(new Twilio.Types.PhoneNumber($"whatsapp:{formattedNumber}"))
                    {
                        From = new Twilio.Types.PhoneNumber($"whatsapp:{twilioFrom}"),
                        ContentSid = "HX229f5a04fd0510ce1b071852155d3e75",
                        ContentVariables = $"{{\"1\":\"{otpCode}\"}}"
                    };

                    await MessageResource.CreateAsync(messageOptions);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Twilio WhatsApp Send Error: {ex.Message}");
                }
            }

            return new SendOtpResponseDto
            {
                Message = "OTP sent successfully via WhatsApp",
                Otp = otpCode // Returning OTP in response for test/fallback simulated environment
            };
        }

        public async Task<AuthResponseDto> VerifyOtpAsync(VerifyOtpRequestDto request, string ipAddress)
        {
            var otp = await _otpRepository.GetLatestOtpAsync(request.MobileNumber);

            if (otp == null || otp.OtpCode != request.Otp || otp.ExpiresAt < DateTime.UtcNow || otp.IsVerified)
            {
                throw new Exception("Invalid or expired OTP");
            }

            otp.IsVerified = true;
            await _otpRepository.UpdateAsync(otp);

            var user = await _userRepository.GetByMobileNumberAsync(request.MobileNumber);
            if (user == null)
            {
                // New user - do not issue tokens yet, profile registration is required
                return new AuthResponseDto
                {
                    IsNewUser = true,
                    User = new UserDto { MobileNumber = request.MobileNumber }
                };
            }

            // Existing user - generate tokens
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

        public async Task<AuthResponseDto> RefreshTokenAsync(RefreshTokenRequestDto request, string ipAddress)
        {
            var existingToken = await _refreshTokenRepository.GetByTokenAsync(request.RefreshToken);

            if (existingToken == null)
            {
                throw new Exception("Invalid token");
            }

            // Security check: Token Reuse Detection
            if (existingToken.IsRevoked)
            {
                // Revoke all tokens in this user lineage (for safety)
                throw new Exception("Security Alert: Token reuse detected. Please re-authenticate.");
            }

            if (existingToken.IsExpired)
            {
                throw new Exception("Token has expired");
            }

            var user = await _userRepository.GetByIdAsync(existingToken.UserId);
            if (user == null)
            {
                throw new Exception("User not found");
            }

            // Revoke current token (rotate)
            var newRefreshTokenString = GenerateRefreshTokenString();
            existingToken.IsRevoked = true;
            existingToken.RevokedDate = DateTime.UtcNow;
            existingToken.RevokedByIp = ipAddress;
            existingToken.ReplacedByToken = newRefreshTokenString;
            await _refreshTokenRepository.UpdateAsync(existingToken);

            // Create new token
            var newRefreshToken = new RefreshToken
            {
                UserId = user.Id,
                Token = newRefreshTokenString,
                ExpiryDate = DateTime.UtcNow.AddDays(30),
                CreatedByIp = ipAddress,
                DeviceId = request.DeviceId,
                DeviceName = request.DeviceName
            };
            await _refreshTokenRepository.AddAsync(newRefreshToken);

            var (accessToken, accessTokenExpiry) = GenerateJwtToken(user);

            return new AuthResponseDto
            {
                IsNewUser = false,
                AccessToken = accessToken,
                RefreshToken = newRefreshToken.Token,
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

        public async Task<bool> LogoutAsync(LogoutRequestDto request, string ipAddress)
        {
            var token = await _refreshTokenRepository.GetByTokenAsync(request.RefreshToken);
            if (token == null) return false;

            token.IsRevoked = true;
            token.RevokedDate = DateTime.UtcNow;
            token.RevokedByIp = ipAddress;

            await _refreshTokenRepository.UpdateAsync(token);
            return true;
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
            // Check and revoke any existing active token for the device
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
