using System;
using System.ComponentModel.DataAnnotations;

namespace CooRent.Api.Core.Entities
{
    public class VehicleSuggestion
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Required]
        [MaxLength(100)]
        public string CategoryName { get; set; } = string.Empty;

        [Required]
        [MaxLength(150)]
        public string Title { get; set; } = string.Empty;

        [Required]
        [MaxLength(500)]
        public string Description { get; set; } = string.Empty;

        [Required]
        [MaxLength(200)]
        public string PriceDetails { get; set; } = string.Empty;

        [Required]
        [MaxLength(300)]
        public string ImageUrl { get; set; } = string.Empty;

        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    }
}
