using FluentValidation;
using CooRent.Api.Core.DTOs;

namespace CooRent.Api.Api.Validators
{
    public class SendOtpRequestValidator : AbstractValidator<SendOtpRequestDto>
    {
        public SendOtpRequestValidator()
        {
            RuleFor(x => x.MobileNumber)
                .NotEmpty().WithMessage("Mobile number is required.")
                .Length(10).WithMessage("Mobile number must be exactly 10 digits.")
                .Matches(@"^\d{10}$").WithMessage("Mobile number must contain only numeric characters.");
        }
    }

    public class VerifyOtpRequestValidator : AbstractValidator<VerifyOtpRequestDto>
    {
        public VerifyOtpRequestValidator()
        {
            RuleFor(x => x.MobileNumber)
                .NotEmpty().WithMessage("Mobile number is required.")
                .Length(10).WithMessage("Mobile number must be exactly 10 digits.")
                .Matches(@"^\d{10}$").WithMessage("Mobile number must contain only numeric characters.");

            RuleFor(x => x.Otp)
                .NotEmpty().WithMessage("OTP is required.")
                .Length(6).WithMessage("OTP must be exactly 6 digits.")
                .Matches(@"^\d{6}$").WithMessage("OTP must contain only numeric characters.");
        }
    }

    public class RegisterUserRequestValidator : AbstractValidator<RegisterUserRequestDto>
    {
        public RegisterUserRequestValidator()
        {
            RuleFor(x => x.MobileNumber)
                .NotEmpty().WithMessage("Mobile number is required.")
                .Length(10).WithMessage("Mobile number must be exactly 10 digits.")
                .Matches(@"^\d{10}$").WithMessage("Mobile number must contain only numeric characters.");

            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Full Name is required.")
                .MaximumLength(100).WithMessage("Full Name must not exceed 100 characters.");
        }
    }

    public class UpdateUserRequestValidator : AbstractValidator<UpdateUserRequestDto>
    {
        public UpdateUserRequestValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Full Name is required.")
                .MaximumLength(100).WithMessage("Full Name must not exceed 100 characters.");
        }
    }
}
