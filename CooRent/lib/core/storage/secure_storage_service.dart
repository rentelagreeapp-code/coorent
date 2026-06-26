import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userDataKey = 'user_data';

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveTokenExpiry(String expiry) async {
    await _storage.write(key: _tokenExpiryKey, value: expiry);
  }

  Future<String?> getTokenExpiry() async {
    return await _storage.read(key: _tokenExpiryKey);
  }

  Future<void> saveUserData(String userDataJson) async {
    await _storage.write(key: _userDataKey, value: userDataJson);
  }

  Future<String?> getUserData() async {
    return await _storage.read(key: _userDataKey);
  }

  Future<void> clearAuthData() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenExpiryKey);
    await _storage.delete(key: _userDataKey);
  }
}
