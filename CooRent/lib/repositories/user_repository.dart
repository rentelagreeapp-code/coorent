import 'package:dio/dio.dart';
import 'package:coorent/core/api/api_client.dart';
import 'package:coorent/core/constants/api_constants.dart';
import 'package:coorent/models/user_model.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.profile);
      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load profile');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load profile');
    }
  }

  Future<UserModel> updateProfile(String name) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConstants.updateProfile,
        data: {'name': name},
      );
      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update profile');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update profile');
    }
  }
}
