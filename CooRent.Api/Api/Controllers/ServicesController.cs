using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CooRent.Api.Core.DTOs;
using CooRent.Api.Core.Entities;
using CooRent.Api.Infrastructure.Data;

namespace CooRent.Api.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ServicesController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public ServicesController(ApplicationDbContext context)
        {
            _context = context;
        }
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var services = await _context.Set<RentalService>().ToListAsync();
            return Ok(ApiResponse<List<RentalService>>.SuccessResponse(services, "All services retrieved successfully"));
        }
        [HttpGet("{categoryName}")]
        public async Task<IActionResult> GetByCategory(string categoryName)
        {
            var services = await _context.Set<RentalService>()
                .Where(s => s.CategoryName.ToLower() == categoryName.ToLower())
                .ToListAsync();

            // Insert sample seed items if database is currently empty
            if (!services.Any())
            {
                services = GetSeedData(categoryName);
                await _context.AddRangeAsync(services);
                await _context.SaveChangesAsync();
            }

            return Ok(ApiResponse<List<RentalService>>.SuccessResponse(services, "Services retrieved successfully"));
        }

        private List<RentalService> GetSeedData(string categoryName)
        {
            return new List<RentalService>
            {
                new() {
                    CategoryName = categoryName,
                    Title = $"{categoryName} Pro Max",
                    Description = "Equipped with advanced GPS systems and automatic steering capabilities.",
                    PriceDetails = "₹1,200 / hr",
                    ImageUrl = "https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&q=80&w=200"
                },
                new() {
                    CategoryName = categoryName,
                    Title = $"{categoryName} Standard Edition",
                    Description = "Standard workhorse utility machine, fuel efficient and reliable.",
                    PriceDetails = "₹800 / hr",
                    ImageUrl = "https://images.unsplash.com/photo-1594142426462-a57bbd222c11?auto=format&fit=crop&q=80&w=200"
                }
            };
        }
    }
}
