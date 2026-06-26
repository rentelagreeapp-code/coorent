class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5000';
  
  static const String sendOtp = '/api/auth/send-otp';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String logout = '/api/auth/logout';
  
  static const String register = '/api/user/register';
  static const String profile = '/api/user/profile';
  static const String updateProfile = '/api/user/update';
}
