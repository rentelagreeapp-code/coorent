class RentalServiceModel {
  final String id;
  final String categoryId;
  final String categoryName;
  final String title;
  final String description;
  final String priceDetails;
  final String imageUrl;
  final double? latitude;
  final double? longitude;

  RentalServiceModel({
    required this.id,
    this.categoryId = '',
    required this.categoryName,
    required this.title,
    required this.description,
    required this.priceDetails,
    required this.imageUrl,
    this.latitude,
    this.longitude,
  });

  factory RentalServiceModel.fromJson(Map<String, dynamic> json) {
    return RentalServiceModel(
      id: json['id'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priceDetails: json['priceDetails'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }
}
