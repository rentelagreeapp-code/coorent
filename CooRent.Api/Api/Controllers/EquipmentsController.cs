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

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] Equipment equipment)
        {
            if (equipment == null)
                return BadRequest(ApiResponse<string>.FailureResponse("Invalid equipment data"));

            await _context.Equipments.AddAsync(equipment);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<Equipment>.SuccessResponse(equipment, "Equipment added successfully"));
        }
    }
}
