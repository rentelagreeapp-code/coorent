import 'package:dio/dio.dart';
import 'package:coorent/core/api/api_client.dart';
import 'package:coorent/core/constants/api_constants.dart';
import 'package:coorent/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.sendOtp,
        data: {'mobileNumber': mobileNumber},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to send OTP');
    }
  }

  Future<AuthTokensModel> verifyOtp(String mobileNumber, String otp, String deviceId) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.verifyOtp,
        data: {
          'mobileNumber': mobileNumber,
          'otp': otp,
          'deviceId': deviceId,
          'deviceName': 'Mobile Device',
        },
      );
      if (response.data['success'] == true) {
        return AuthTokensModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'OTP verification failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'OTP verification failed');
    }
  }

  Future<AuthTokensModel> registerUser(String mobileNumber, String name, String deviceId) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.register,
        data: {
          'mobileNumber': mobileNumber,
          'name': name,
          'deviceId': deviceId,
          'deviceName': 'Mobile Device',
        },
      );
      if (response.data['success'] == true) {
        return AuthTokensModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Registration failed');
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _apiClient.dio.post(
        ApiConstants.logout,
        data: {'refreshToken': refreshToken},
      );
    } catch (_) {
      // Complete cleanup even if logout API fails or is offline
    }
  }
}
