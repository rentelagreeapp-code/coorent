using System;
using System.ComponentModel.DataAnnotations;

namespace CooRent.Api.Core.Entities
{
    public class RefreshToken
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Required]
        public Guid UserId { get; set; }

        [Required]
        [MaxLength(200)]
        public string Token { get; set; } = string.Empty;

        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;

        public DateTime ExpiryDate { get; set; }

        [MaxLength(50)]
        public string CreatedByIp { get; set; } = string.Empty;

        public DateTime? RevokedDate { get; set; }

        [MaxLength(50)]
        public string RevokedByIp { get; set; } = string.Empty;

        [MaxLength(200)]
        public string ReplacedByToken { get; set; } = string.Empty;

        [MaxLength(100)]
        public string DeviceId { get; set; } = string.Empty;

        [MaxLength(100)]
        public string DeviceName { get; set; } = string.Empty;

        public bool IsRevoked { get; set; } = false;

        public bool IsExpired => DateTime.UtcNow >= ExpiryDate;

        public bool IsActive => !IsRevoked && !IsExpired;
    }
}
