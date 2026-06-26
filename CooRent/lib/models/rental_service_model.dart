class RentalServiceModel {
  final String id;
  final String categoryName;
  final String title;
  final String description;
  final String priceDetails;
  final String imageUrl;

  RentalServiceModel({
    required this.id,
    required this.categoryName,
    required this.title,
    required this.description,
    required this.priceDetails,
    required this.imageUrl,
  });

  factory RentalServiceModel.fromJson(Map<String, dynamic> json) {
    return RentalServiceModel(
      id: json['id'] ?? '',
      categoryName: json['categoryName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priceDetails: json['priceDetails'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
