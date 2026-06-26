namespace CooRent.Api.Core.DTOs
{
    public class AdminLoginRequestDto
    {
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }

    public class AdminLoginResponseDto
    {
        public string Token { get; set; } = string.Empty;
        public string Username { get; set; } = string.Empty;
    }

    public class CreateRentalServiceRequestDto
    {
        public string CategoryName { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string PriceDetails { get; set; } = string.Empty;
        public string ImageUrl { get; set; } = string.Empty;
    }
}
