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
    public class VehicleSuggestionsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public VehicleSuggestionsController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var suggestions = await _context.VehicleSuggestions.ToListAsync();

            if (!suggestions.Any())
            {
                var seedData = GetDefaultSeedData();
                await _context.VehicleSuggestions.AddRangeAsync(seedData);
                await _context.SaveChangesAsync();
                suggestions = seedData;
            }

            return Ok(ApiResponse<List<VehicleSuggestion>>.SuccessResponse(suggestions, "All vehicle suggestions retrieved successfully"));
        }

        [HttpGet("{categoryName}")]
        public async Task<IActionResult> GetByCategory(string categoryName)
        {
            var suggestions = await _context.VehicleSuggestions
                .Where(s => s.CategoryName.ToLower() == categoryName.ToLower())
                .ToListAsync();

            if (!suggestions.Any())
            {
                var seedData = GetSeedData(categoryName);
                await _context.VehicleSuggestions.AddRangeAsync(seedData);
                await _context.SaveChangesAsync();
                suggestions = seedData;
            }

            return Ok(ApiResponse<List<VehicleSuggestion>>.SuccessResponse(suggestions, $"Vehicle suggestions for {categoryName} retrieved successfully"));
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] VehicleSuggestion suggestion)
        {
            if (suggestion == null)
                return BadRequest(ApiResponse<string>.FailureResponse("Invalid suggestion data"));

            await _context.VehicleSuggestions.AddAsync(suggestion);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<VehicleSuggestion>.SuccessResponse(suggestion, "Vehicle suggestion created successfully"));
        }

        private List<VehicleSuggestion> GetDefaultSeedData()
        {
            return new List<VehicleSuggestion>
            {
                new() {
                    CategoryName = "Tractors",
                    Title = "John Deere 5050D Tractor",
                    Description = "Reliable 50 HP tractor suitable for plowing, tilling, and heavy haulage. Equipped with power steering.",
                    PriceDetails = "₹2500 / Day",
                    ImageUrl = "https://wydzxchvnkwpucmgomdz.supabase.co/storage/v1/object/public/coorent/Gemini_Generated_Image_pfpns2pfpns2pfpn-removebg-preview%20(1).png"
                },
                new() {
                    CategoryName = "JCB",
                    Title = "JCB 3DX Backhoe Loader",
                    Description = "Heavy-duty backhoe loader ideal for farm excavation, land clearing, and general earthmoving tasks.",
                    PriceDetails = "₹8000 / Day",
                    ImageUrl = "https://pngimg.com/uploads/excavator/excavator_PNG16.png"
                },
                new() {
                    CategoryName = "Cars",
                    Title = "Mahindra Bolero Camper (4x4)",
                    Description = "Sturdy 4x4 pickup utility car, ideal for transporting farm produce and navigating rough rural terrains.",
                    PriceDetails = "₹3500 / Day",
                    ImageUrl = "https://pngimg.com/uploads/suv/suv_PNG101252.png"
                },
                new() {
                    CategoryName = "Drones",
                    Title = "DJI Agras T40 Spraying Drone",
                    Description = "Advanced agricultural drone featuring coaxial twin rotors and a 40 kg spraying payload for crop care.",
                    PriceDetails = "₹9500 / Day",
                    ImageUrl = "https://pngimg.com/uploads/drone/drone_PNG9.png"
                }
            };
        }

        private List<VehicleSuggestion> GetSeedData(string categoryName)
        {
            return new List<VehicleSuggestion>
            {
                new() {
                    CategoryName = categoryName,
                    Title = $"{categoryName} Pro Max",
                    Description = "Premium high-capacity vehicle suggestion option equipped with latest features and controls.",
                    PriceDetails = "₹1,200 / hr",
                    ImageUrl = "https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&q=80&w=200"
                },
                new() {
                    CategoryName = categoryName,
                    Title = $"{categoryName} Standard Edition",
                    Description = "Efficient and reliable workhorse option, designed for standard farm or utility workloads.",
                    PriceDetails = "₹800 / hr",
                    ImageUrl = "https://images.unsplash.com/photo-1594142426462-a57bbd222c11?auto=format&fit=crop&q=80&w=200"
                }
            };
        }
    }
}
