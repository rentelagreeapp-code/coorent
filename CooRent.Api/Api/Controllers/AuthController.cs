using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using CooRent.Api.Core.DTOs;
using CooRent.Api.Core.Interfaces;

namespace CooRent.Api.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("send-otp")]
        public async Task<IActionResult> SendOtp([FromBody] SendOtpRequestDto request)
        {
            var response = await _authService.SendOtpAsync(request);
            return Ok(ApiResponse<SendOtpResponseDto>.SuccessResponse(response, "OTP sent successfully"));
        }

        [HttpPost("verify-otp")]
        public async Task<IActionResult> VerifyOtp([FromBody] VerifyOtpRequestDto request)
        {
            var ipAddress = GetIpAddress();
            var response = await _authService.VerifyOtpAsync(request, ipAddress);
            return Ok(ApiResponse<AuthResponseDto>.SuccessResponse(response, "Verification successful"));
        }

        [HttpPost("refresh-token")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequestDto request)
        {
            var ipAddress = GetIpAddress();
            var response = await _authService.RefreshTokenAsync(request, ipAddress);
            return Ok(ApiResponse<AuthResponseDto>.SuccessResponse(response, "Token refreshed successfully"));
        }

        [HttpPost("logout")]
        public async Task<IActionResult> Logout([FromBody] LogoutRequestDto request)
        {
            var ipAddress = GetIpAddress();
            var success = await _authService.LogoutAsync(request, ipAddress);
            if (!success)
            {
                return BadRequest(ApiResponse<string>.FailureResponse("Invalid refresh token or token already revoked"));
            }
            return Ok(ApiResponse<string>.SuccessResponse("Logout successful", "Session invalidated"));
        }

        private string GetIpAddress()
        {
            if (Request.Headers.TryGetValue("X-Forwarded-For", out var header))
            {
                return header.ToString();
            }
            return HttpContext.Connection.RemoteIpAddress?.MapToIPv4().ToString() ?? "127.0.0.1";
        }
    }
}
