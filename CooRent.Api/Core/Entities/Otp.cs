using System;
using System.ComponentModel.DataAnnotations;

namespace CooRent.Api.Core.Entities
{
    public class Otp
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Required]
        [MaxLength(15)]
        public string MobileNumber { get; set; } = string.Empty;

        [Required]
        [MaxLength(6)]
        public string OtpCode { get; set; } = string.Empty;

        public DateTime ExpiresAt { get; set; }

        public bool IsVerified { get; set; } = false;

        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    }
}
