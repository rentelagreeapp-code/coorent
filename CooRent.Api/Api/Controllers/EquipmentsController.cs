using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CooRent.Api.Core.Entities;
using CooRent.Api.Infrastructure.Data;
using CooRent.Api.Core.DTOs;

namespace CooRent.Api.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EquipmentsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public EquipmentsController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var equipments = await _context.Equipments.ToListAsync();
            return Ok(ApiResponse<List<Equipment>>.SuccessResponse(equipments, "Equipments retrieved successfully"));
        }

        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetByUserId(Guid userId)
        {
            var equipments = await _context.Equipments
                .Where(e => e.UserId == userId)
                .ToListAsync();
            return Ok(ApiResponse<List<Equipment>>.SuccessResponse(equipments, "User equipments retrieved successfully"));
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] Equipment equipment)
        {
            if (equipment == null)
                return BadRequest(ApiResponse<string>.FailureResponse("Invalid equipment data"));

            if (string.IsNullOrEmpty(equipment.LocationName) && equipment.Latitude != 0 && equipment.Longitude != 0)
            {
                equipment.LocationName = await ResolveLocationNameAsync(equipment.Latitude, equipment.Longitude);
            }

            await _context.Equipments.AddAsync(equipment);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<Equipment>.SuccessResponse(equipment, "Equipment added successfully"));
        }

        private async Task<string> ResolveLocationNameAsync(double lat, double lng)
        {
            try
            {
                using (var client = new System.Net.Http.HttpClient())
                {
                    client.DefaultRequestHeaders.Add("User-Agent", "CooRentApi/1.0.0");
                    var url = $"https://nominatim.openstreetmap.org/reverse?format=json&lat={lat}&lon={lng}&zoom=10&addressdetails=1";
                    var response = await client.GetAsync(url);
                    if (response.IsSuccessStatusCode)
                    {
                        var json = await response.Content.ReadAsStringAsync();
                        using (var doc = System.Text.Json.JsonDocument.Parse(json))
                        {
                            if (doc.RootElement.TryGetProperty("address", out var address))
                            {
                                string city = null;
                                if (address.TryGetProperty("city", out var cityProp)) city = cityProp.GetString();
                                else if (address.TryGetProperty("town", out var townProp)) city = townProp.GetString();
                                else if (address.TryGetProperty("village", out var villageProp)) city = villageProp.GetString();
                                else if (address.TryGetProperty("suburb", out var suburbProp)) city = suburbProp.GetString();
                                else if (address.TryGetProperty("county", out var countyProp)) city = countyProp.GetString();

                                return city ?? "Unknown City";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error resolving location in backend: {ex.Message}");
            }
            return "Unknown City";
        }
    }
}
