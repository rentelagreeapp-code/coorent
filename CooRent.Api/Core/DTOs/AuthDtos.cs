using System.ComponentModel.DataAnnotations;

namespace CooRent.Api.Core.DTOs
{
    public class SendOtpRequestDto
    {
        public string MobileNumber { get; set; } = string.Empty;
    }

    public class SendOtpResponseDto
    {
        public string Message { get; set; } = string.Empty;
        public string Otp { get; set; } = string.Empty; // For development/test simulation
    }

    public class VerifyOtpRequestDto
    {
        public string MobileNumber { get; set; } = string.Empty;
        public string Otp { get; set; } = string.Empty;
        public string DeviceId { get; set; } = string.Empty;
        public string DeviceName { get; set; } = string.Empty;
    }

    public class AuthResponseDto
    {
        public bool IsNewUser { get; set; }
        public string AccessToken { get; set; } = string.Empty;
        public string RefreshToken { get; set; } = string.Empty;
        public DateTime AccessTokenExpiry { get; set; }
        public UserDto? User { get; set; }
    }

    public class UserDto
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string MobileNumber { get; set; } = string.Empty;
        public bool IsActive { get; set; }
    }

    public class RegisterUserRequestDto
    {
        public string MobileNumber { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string DeviceId { get; set; } = string.Empty;
        public string DeviceName { get; set; } = string.Empty;
    }

    public class UpdateUserRequestDto
    {
        public string Name { get; set; } = string.Empty;
    }

    public class RefreshTokenRequestDto
    {
        public string RefreshToken { get; set; } = string.Empty;
        public string DeviceId { get; set; } = string.Empty;
        public string DeviceName { get; set; } = string.Empty;
    }

    public class LogoutRequestDto
    {
        public string RefreshToken { get; set; } = string.Empty;
    }

    public class ApiResponse<T>
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public T? Data { get; set; }

        public static ApiResponse<T> SuccessResponse(T data, string message = "") =>
            new() { Success = true, Message = message, Data = data };

        public static ApiResponse<T> FailureResponse(string message) =>
            new() { Success = false, Message = message, Data = default };
    }
}
