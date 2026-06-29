import 'package:dio/dio.dart';
import 'package:coorent/core/api/api_client.dart';
import 'package:coorent/models/rental_service_model.dart';

class BookingRepository {
  final ApiClient _apiClient;

  BookingRepository(this._apiClient);

  Future<List<RentalServiceModel>> getServicesByCategory(String categoryName) async {
    try {
      final response = await _apiClient.dio.get('/api/services/$categoryName');
      if (response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        return list.map((item) => RentalServiceModel.fromJson(item)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load services');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load services');
    }
  }

  Future<List<RentalServiceModel>> getAllServices() async {
    try {
      print("aki11");
      final response = await _apiClient.dio.get('/api/services');
      if (response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        print("Sevice list ak123"+list.toString());
        return list.map((item) => RentalServiceModel.fromJson(item)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load services');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load services');
    }
  }
}
