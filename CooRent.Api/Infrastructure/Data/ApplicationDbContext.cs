using Microsoft.EntityFrameworkCore;
using CooRent.Api.Core.Entities;
using System.Text.Json;

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
        public DbSet<Admin> Admins => Set<Admin>();
        public DbSet<Equipment> Equipments => Set<Equipment>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<User>(entity =>
            {
                entity.HasIndex(u => u.MobileNumber).IsUnique();
                entity.Property(u => u.Id).HasColumnName("UserId");
            });

            modelBuilder.Entity<Otp>(entity =>
            {
                entity.HasIndex(o => o.MobileNumber);
            });

            modelBuilder.Entity<RefreshToken>(entity =>
            {
                entity.HasIndex(t => t.Token).IsUnique();
            });

            modelBuilder.Entity<Equipment>(entity =>
            {
                entity.Property(e => e.EquipmentImages)
                    .HasColumnType("jsonb")
                    .HasConversion(
                        v => JsonSerializer.Serialize(v, (JsonSerializerOptions)null),
                        v => JsonSerializer.Deserialize<List<string>>(v, (JsonSerializerOptions)null) ?? new List<string>()
                    );
            });
        }
    }
}
