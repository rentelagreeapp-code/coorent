import 'package:dio/dio.dart';
import 'package:coorent/core/api/api_client.dart';
import 'package:coorent/models/rental_service_model.dart';
import 'package:coorent/models/equipment_model.dart';

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
      print("aki1167567");
      final response = await _apiClient.dio.get('/api/services');

      if (response.data['success'] == true) {
        final List list = response.data['data'] ?? [];

        return list.map((item) => RentalServiceModel.fromJson(item)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load services');
      }
    } on DioException catch (e) {
      print(e);
      throw Exception(e.response?.data['message'] ?? 'Failed to load services');
    }
  }

  Future<RentalServiceModel> createService(RentalServiceModel service) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/services',
        data: {
          'categoryName': service.categoryName,
          'title': service.title,
          'description': service.description,
          'priceDetails': service.priceDetails,
          'imageUrl': service.imageUrl,
          'latitude': service.latitude,
          'longitude': service.longitude,
        },
      );
      if (response.data['success'] == true) {
        return RentalServiceModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create service');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create service');
    }
  }

  Future<List<EquipmentModel>> getAllEquipments() async {
    try {
      final response = await _apiClient.dio.get('/api/equipments');
      if (response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        return list.map((item) => EquipmentModel.fromJson(item)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load equipments');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load equipments');
    }
  }

  Future<List<EquipmentModel>> getEquipmentsByUserId(String userId) async {
    try {
      final response = await _apiClient.dio.get('/api/equipments/user/$userId');
      if (response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        return list.map((item) => EquipmentModel.fromJson(item)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load user equipments');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load user equipments');
    }
  }

  Future<EquipmentModel> createEquipment(EquipmentModel equipment) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/equipments',
        data: equipment.toJson(),
      );
      if (response.data['success'] == true) {
        return EquipmentModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create equipment');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create equipment');
    }
  }
}
