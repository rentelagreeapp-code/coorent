class EquipmentModel {
  final String id;
  final String categoryId;
  final String userId;
  final String equipmentName;
  final String description;
  final String price;
  final double latitude;
  final double longitude;
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
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['id'] ?? '',
      categoryId: json['categoryId'] ?? '',
      userId: json['userId'] ?? '',
      equipmentName: json['equipmentName'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      equipmentImages: List<String>.from(json['equipmentImages'] ?? []),
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
    };
  }
}
