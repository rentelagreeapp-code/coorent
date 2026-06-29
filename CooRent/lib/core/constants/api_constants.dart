import 'dart:io';

class ApiConstants {
  static String get baseUrl {
    // 10.0.2.2 is the gateway to host localhost for Android Emulators
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5041';
    }
    return 'http://localhost:5041';
  }
  
  static const String sendOtp = '/api/auth/send-otp';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String logout = '/api/auth/logout';
  
  static const String register = '/api/user/register';
  static const String profile = '/api/user/profile';
  static const String updateProfile = '/api/user/update';
}
