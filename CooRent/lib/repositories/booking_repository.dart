import 'package:dio/dio.dart';
import 'package:coorent/core/api/api_client.dart';
import 'package:coorent/models/rental_service_model.dart';
import 'package:coorent/models/equipment_model.dart';

class BookingRepository {
  final ApiClient _apiClient;
  
  // Local cache memory store for rental services/categories
  List<RentalServiceModel> _cachedServices = [];

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

  Future<List<RentalServiceModel>> getAllServices({bool forceRefresh = false}) async {
    if (_cachedServices.isNotEmpty && !forceRefresh) {
      return _cachedServices;
    }
    try {
      final response = await _apiClient.dio.get('/api/services');

      if (response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        _cachedServices = list.map((item) => RentalServiceModel.fromJson(item)).toList();
        return _cachedServices;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load services');
      }
    } on DioException catch (e) {
      print(e);
      throw Exception(e.response?.data['message'] ?? 'Failed to load services');
    }
  }

  void clearServicesCache() {
    _cachedServices.clear();
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

  Future<List<EquipmentModel>> getAllEquipments({String? categoryId, String? locationName}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/equipments',
        queryParameters: {
          if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
          if (locationName != null && locationName.isNotEmpty) 'locationName': locationName,
        },
      );
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
      print("esdfd vfdr e"+e.toString());
      throw Exception(e.response?.data['message'] ?? 'Failed to create equipment');
    }
  }

  Future<EquipmentModel> updateEquipment(String id, EquipmentModel equipment) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/equipments/$id',
        data: equipment.toJson(),
      );
      if (response.data['success'] == true) {
        return EquipmentModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update equipment');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update equipment');
    }
  }

  Future<void> deleteEquipment(String id) async {
    try {
      final response = await _apiClient.dio.delete('/api/equipments/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete equipment');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete equipment');
    }
  }
}
