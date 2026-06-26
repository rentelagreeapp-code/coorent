using System;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using CooRent.Api.Core.DTOs;
using CooRent.Api.Core.Interfaces;

namespace CooRent.Api.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;

        public UserController(IUserService userService)
        {
            _userService = userService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterUserRequestDto request)
        {
            var ipAddress = GetIpAddress();
            var response = await _userService.RegisterAsync(request, ipAddress);
            return Ok(ApiResponse<AuthResponseDto>.SuccessResponse(response, "User registered successfully"));
        }

        [Authorize]
        [HttpGet("profile")]
        public async Task<IActionResult> GetProfile()
        {
            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            {
                return Unauthorized(ApiResponse<string>.FailureResponse("Unauthorized access"));
            }

            var profile = await _userService.GetProfileAsync(userId);
            return Ok(ApiResponse<UserDto>.SuccessResponse(profile, "Profile retrieved successfully"));
        }

        [Authorize]
        [HttpPut("update")]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateUserRequestDto request)
        {
            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            {
                return Unauthorized(ApiResponse<string>.FailureResponse("Unauthorized access"));
            }

            var updatedProfile = await _userService.UpdateProfileAsync(userId, request);
            return Ok(ApiResponse<UserDto>.SuccessResponse(updatedProfile, "Profile updated successfully"));
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
