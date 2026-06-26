using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using CooRent.Api.Core.DTOs;
using CooRent.Api.Core.Entities;
using CooRent.Api.Infrastructure.Data;

namespace CooRent.Api.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AdminController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IConfiguration _configuration;

        public AdminController(ApplicationDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] AdminLoginRequestDto request)
        {
            // Seed a default admin on the fly if table is empty
            var anyAdmin = await _context.Admins.AnyAsync();
            if (!anyAdmin)
            {
                var defaultAdmin = new Admin
                {
                    Username = "admin",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin123") // admin123 default
                };
                await _context.Admins.AddAsync(defaultAdmin);
                await _context.SaveChangesAsync();
            }

            var admin = await _context.Admins.FirstOrDefaultAsync(a => a.Username == request.Username);
            if (admin == null || !BCrypt.Net.BCrypt.Verify(request.Password, admin.PasswordHash))
            {
                // BYPASS OPTION: Check for custom bypass login bypass userid & password as requested
                if (request.Username == "admin" && request.Password == "admin123")
                {
                    // Proceed to login bypass
                }
                else
                {
                    return BadRequest(ApiResponse<string>.FailureResponse("Invalid admin credentials"));
                }
            }

            var token = GenerateAdminJwtToken(request.Username);

            return Ok(ApiResponse<AdminLoginResponseDto>.SuccessResponse(new AdminLoginResponseDto
            {
                Token = token,
                Username = request.Username
            }, "Admin login successful"));
        }

        [Authorize]
        [HttpPost("services")]
        public async Task<IActionResult> CreateService([FromBody] CreateRentalServiceRequestDto request)
        {
            var service = new RentalService
            {
                CategoryName = request.CategoryName,
                Title = request.Title,
                Description = request.Description,
                PriceDetails = request.PriceDetails,
                ImageUrl = request.ImageUrl
            };

            await _context.Set<RentalService>().AddAsync(service);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<RentalService>.SuccessResponse(service, "Service created successfully"));
        }

        [Authorize]
        [HttpGet("services")]
        public async Task<IActionResult> GetAllServices()
        {
            var services = await _context.Set<RentalService>().ToListAsync();
            return Ok(ApiResponse<List<RentalService>>.SuccessResponse(services, "Services retrieved successfully"));
        }

        [Authorize]
        [HttpDelete("services/{id}")]
        public async Task<IActionResult> DeleteService(Guid id)
        {
            var service = await _context.Set<RentalService>().FindAsync(id);
            if (service == null) return NotFound(ApiResponse<string>.FailureResponse("Service not found"));

            _context.Set<RentalService>().Remove(service);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<string>.SuccessResponse("Service deleted successfully", "Catalog updated"));
        }

        private string GenerateAdminJwtToken(string username)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var keyStr = _configuration["Jwt:Key"] ?? "super_secret_coorent_key_long_enough_to_meet_requirements_2026_06_26";
            var key = Encoding.ASCII.GetBytes(keyStr);

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
                    new Claim(ClaimTypes.NameIdentifier, username),
                    new Claim(ClaimTypes.Role, "Admin")
                }),
                Expires = DateTime.UtcNow.AddHours(2),
                Issuer = _configuration["Jwt:Issuer"] ?? "CooRent",
                Audience = _configuration["Jwt:Audience"] ?? "CooRentMobile",
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }
    }
}
