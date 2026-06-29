using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace CooRent.Api.Core.Entities
{
    public class Equipment
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Required]
        public Guid CategoryId { get; set; }

        [Required]
        public Guid UserId { get; set; }

        [Required]
        [MaxLength(200)]
        public string EquipmentName { get; set; } = string.Empty;

        [Required]
        [MaxLength(1000)]
        public string Description { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string Price { get; set; } = string.Empty;

        public double Latitude { get; set; }
        public double Longitude { get; set; }

        // Equipment Images stored as list of URL strings
        public List<string> EquipmentImages { get; set; } = new();

        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    }
}
