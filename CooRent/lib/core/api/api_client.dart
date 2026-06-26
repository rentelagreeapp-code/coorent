import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coorent/core/storage/secure_storage_service.dart';

class ApiClient {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:5000', // Default Android Emulator Loopback Address
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ),
  );

  final SecureStorageService _storage = SecureStorageService();
  bool _isRefreshing = false;
  final List<Completer<String?>> _failedQueue = [];

  ApiClient() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final requestOptions = error.requestOptions;

            // Queue requests if token refresh is already in progress
            if (_isRefreshing) {
              final completer = Completer<String?>();
              _failedQueue.add(completer);
              try {
                final newToken = await completer.future;
                if (newToken != null) {
                  requestOptions.headers['Authorization'] = 'Bearer $newToken';
                  final response = await dio.fetch(requestOptions);
                  return handler.resolve(response);
                }
              } catch (e) {
                return handler.next(error);
              }
            }

            _isRefreshing = true;

            try {
              final refreshToken = await _storage.getRefreshToken();
              final deviceId = await _getDeviceId();
              
              if (refreshToken == null || refreshToken.isEmpty) {
                _logout();
                return handler.next(error);
              }

              // Perform Refresh Token call
              final refreshResponse = await dio.post(
                '/api/auth/refresh-token',
                data: {
                  'refreshToken': refreshToken,
                  'deviceId': deviceId,
                  'deviceName': 'Mobile Device',
                },
              );

              if (refreshResponse.statusCode == 200 && refreshResponse.data['success'] == true) {
                final data = refreshResponse.data['data'];
                final newAccess = data['accessToken'];
                final newRefresh = data['refreshToken'];

                await _storage.saveAccessToken(newAccess);
                await _storage.saveRefreshToken(newRefresh);
                await _storage.saveTokenExpiry(data['accessTokenExpiry']);

                // Process queued requests
                for (var completer in _failedQueue) {
                  completer.complete(newAccess);
                }
                _failedQueue.clear();

                requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                final response = await dio.fetch(requestOptions);
                return handler.resolve(response);
              } else {
                _logout();
              }
            } catch (e) {
              for (var completer in _failedQueue) {
                completer.completeError(e);
              }
              _failedQueue.clear();
              _logout();
            } finally {
              _isRefreshing = false;
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('device_id', deviceId);
    }
    return deviceId;
  }

  void _logout() async {
    await _storage.clearAuthData();
    getx.Get.offAllNamed('/login');
  }
}
