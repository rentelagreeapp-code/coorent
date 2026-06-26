using Microsoft.EntityFrameworkCore;
using CooRent.Api.Core.Entities;

namespace CooRent.Api.Infrastructure.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users => Set<User>();
        public DbSet<Otp> Otps => Set<Otp>();
        public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
        public DbSet<RentalService> RentalServices => Set<RentalService>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<User>(entity =>
            {
                entity.HasIndex(u => u.MobileNumber).IsUnique();
            });

            modelBuilder.Entity<Otp>(entity =>
            {
                entity.HasIndex(o => o.MobileNumber);
            });

            modelBuilder.Entity<RefreshToken>(entity =>
            {
                entity.HasIndex(t => t.Token).IsUnique();
            });
        }
    }
}
