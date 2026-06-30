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
            return Ok(ApiResponse<List<VehicleSuggestion>>.SuccessResponse(suggestions, "All vehicle suggestions retrieved successfully"));
        }

        [HttpGet("{categoryName}")]
        public async Task<IActionResult> GetByCategory(string categoryName)
        {
            var suggestions = await _context.VehicleSuggestions
                .Where(s => s.CategoryName.ToLower() == categoryName.ToLower())
                .ToListAsync();

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
    }
}
