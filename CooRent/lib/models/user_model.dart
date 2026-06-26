class UserModel {
  final String id;
  final String name;
  final String mobileNumber;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobileNumber': mobileNumber,
      'isActive': isActive,
    };
  }
}

class AuthTokensModel {
  final String accessToken;
  final String refreshToken;
  final String accessTokenExpiry;
  final bool isNewUser;
  final UserModel? user;

  AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiry,
    required this.isNewUser,
    this.user,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      accessTokenExpiry: json['accessTokenExpiry'] ?? '',
      isNewUser: json['isNewUser'] ?? false,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
