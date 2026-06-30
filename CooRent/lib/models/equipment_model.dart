import 'dart:convert';

class EquipmentModel {
  final String id;
  final String categoryId;
  final String userId;
  final String equipmentName;
  final String description;
  final String price;
  final double latitude;
  final double longitude;
  final String locationName;
  final List<String> equipmentImages;

  EquipmentModel({
    required this.id,
    required this.categoryId,
    required this.userId,
    required this.equipmentName,
    required this.description,
    required this.price,
    required this.latitude,
    required this.longitude,
    required this.equipmentImages,
    required this.locationName,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    var rawImages = json['equipmentImages'] ?? json['EquipmentImages'];
    List<String> parsedImages = [];
    if (rawImages != null) {
      if (rawImages is List) {
        parsedImages = List<String>.from(rawImages.map((e) => e.toString()));
      } else if (rawImages is String && rawImages.isNotEmpty) {
        try {
          final decoded = jsonDecode(rawImages);
          if (decoded is List) {
            parsedImages = List<String>.from(decoded.map((e) => e.toString()));
          } else {
            parsedImages = [rawImages];
          }
        } catch (_) {
          parsedImages = [rawImages];
        }
      }
    }

    return EquipmentModel(
      id: json['id']?.toString() ?? json['Id']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? json['CategoryId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['UserId']?.toString() ?? '',
      equipmentName: json['equipmentName']?.toString() ?? json['EquipmentName']?.toString() ?? '',
      description: json['description']?.toString() ?? json['Description']?.toString() ?? '',
      price: json['price']?.toString() ?? json['Price']?.toString() ?? '',
      latitude: (json['latitude'] ?? json['Latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] ?? json['Longitude'] as num?)?.toDouble() ?? 0.0,
      equipmentImages: parsedImages,
      locationName: json['locationName']?.toString() ?? json['LocationName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'categoryId': categoryId,
      'userId': userId,
      'equipmentName': equipmentName,
      'description': description,
      'price': price,
      'latitude': latitude,
      'longitude': longitude,
      'equipmentImages': equipmentImages,
      'locationName': locationName,
    };
  }
}
