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
            var services = await _context.Set<RentalService>()
                .Where(s => !s.IsDeleted)
                .ToListAsync();

            // Auto-seed sample master data if database has no active services
            if (!services.Any())
            {
                var seedData = new List<RentalService>
                {
                    new() {
                        CategoryName = "Tractors",
                        Title = "John Deere 5050D",
                        Description = "Reliable 50 HP tractor suitable for plowing, tilling, and heavy haulage.",
                        PriceDetails = "₹2,500 / Day",
                        ImageUrl = "https://wydzxchvnkwpucmgomdz.supabase.co/storage/v1/object/public/coorent/Gemini_Generated_Image_pfpns2pfpns2pfpn-removebg-preview%20(1).png",
                        Latitude = 28.6139,
                        Longitude = 77.2090
                    },
                    new() {
                        CategoryName = "JCB",
                        Title = "JCB 3DX Backhoe Loader",
                        Description = "Heavy-duty backhoe loader ideal for farm excavation and land clearing.",
                        PriceDetails = "₹8,000 / Day",
                        ImageUrl = "https://pngimg.com/uploads/excavator/excavator_PNG16.png",
                        Latitude = 28.6250,
                        Longitude = 77.2150
                    },
                    new() {
                        CategoryName = "Cars",
                        Title = "Mahindra Bolero Camper (4x4)",
                        Description = "Sturdy 4x4 pickup utility car, ideal for transporting farm produce.",
                        PriceDetails = "₹3,500 / Day",
                        ImageUrl = "https://pngimg.com/uploads/suv/suv_PNG101252.png",
                        Latitude = 28.6050,
                        Longitude = 77.2000
                    },
                    new() {
                        CategoryName = "Drones",
                        Title = "DJI Agras T40 Spraying Drone",
                        Description = "Advanced agricultural drone featuring coaxial twin rotors and a 40 kg spraying payload.",
                        PriceDetails = "₹9,500 / Day",
                        ImageUrl = "https://pngimg.com/uploads/drone/drone_PNG9.png",
                        Latitude = 28.6180,
                        Longitude = 77.2250
                    }
                };
                await _context.AddRangeAsync(seedData);
                await _context.SaveChangesAsync();
                services = seedData;
            }

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

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] RentalService service)
        {
            if (service == null) 
                return BadRequest(ApiResponse<string>.FailureResponse("Invalid service data"));

            await _context.Set<RentalService>().AddAsync(service);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<RentalService>.SuccessResponse(service, "Service created successfully"));
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
