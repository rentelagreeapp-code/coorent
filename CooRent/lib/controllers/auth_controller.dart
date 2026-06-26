import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coorent/core/storage/secure_storage_service.dart';
import 'package:coorent/repositories/auth_repository.dart';
import 'package:coorent/models/user_model.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final SecureStorageService _storage = SecureStorageService();

  AuthController(this._authRepository);

  var isLoading = false.obs;
  var mobileNumber = ''.obs;
  var otpCode = ''.obs;
  var verificationOtp = ''.obs; // Server-sent OTP preview for simulation
  var currentUserId = ''.obs;
  var currentUser = Rxn<UserModel>();

  // Countdown timer for OTP Screen
  var countdown = 30.obs;
  var canResend = false.obs;
  Worker? _timerWorker;

  void startTimer() {
    countdown.value = 30;
    canResend.value = false;
    _timerWorker?.dispose();
    _timerWorker = ever(countdown, (int value) {
      if (value > 0) {
        Future.delayed(const Duration(seconds: 1), () {
          if (countdown.value > 0) countdown.value--;
        });
      } else {
        canResend.value = true;
      }
    });
    countdown.value = 29; // Trigger initial decrement
  }

  @override
  void onClose() {
    _timerWorker?.dispose();
    super.onClose();
  }

  Future<void> checkAuthentication() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash Screen delay
    final accessToken = await _storage.getAccessToken();
    final refreshToken = await _storage.getRefreshToken();
    final expiryStr = await _storage.getTokenExpiry();
    final userJson = await _storage.getUserData();

    if (accessToken != null && refreshToken != null && expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);
      if (expiry.isAfter(DateTime.now())) {
        if (userJson != null) {
          currentUser.value = UserModel.fromJson(jsonDecode(userJson));
        }
        Get.offAllNamed('/dashboard');
        return;
      } else {
        // Access Token expired, ApiClient interceptor will try refreshing on first call.
        // For splash safety, navigate to dashboard where APIs will trigger refresh,
        // or trigger a dry-run auth refresh check here.
        if (userJson != null) {
          currentUser.value = UserModel.fromJson(jsonDecode(userJson));
        }
        Get.offAllNamed('/dashboard');
        return;
      }
    }
    Get.offAllNamed('/login');
  }

  Future<void> sendOtpCode(String mobile) async {
    isLoading.value = true;
    try {
      mobileNumber.value = mobile;
      final response = await _authRepository.sendOtp(mobile);
      verificationOtp.value = response['data']['otp'] ?? '';
      
      Get.snackbar(
        'OTP Sent',
        'Your test OTP code is: ${verificationOtp.value}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.indigo.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 8),
      );

      Get.toNamed('/otp');
      startTimer();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtpCode(String code) async {
    isLoading.value = true;
    try {
      otpCode.value = code;
      final deviceId = await _getDeviceId();
      final authData = await _authRepository.verifyOtp(mobileNumber.value, code, deviceId);

      if (authData.isNewUser) {
        Get.toNamed('/register');
      } else {
        await _saveAuthSession(authData);
        Get.offAllNamed('/dashboard');
      }
    } catch (e) {
      Get.snackbar(
        'Verification Failed', 
        e.toString().replaceAll('Exception:', ''), 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerAndCreateProfile(String name) async {
    isLoading.value = true;
    try {
      final deviceId = await _getDeviceId();
      final authData = await _authRepository.registerUser(mobileNumber.value, name, deviceId);

      await _saveAuthSession(authData);
      Get.offAllNamed('/dashboard');
    } catch (e) {
      Get.snackbar('Registration Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logoutUser() async {
    isLoading.value = true;
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        await _authRepository.logout(refreshToken);
      }
    } catch (_) {
    } finally {
      await _storage.clearAuthData();
      currentUser.value = null;
      isLoading.value = false;
      Get.offAllNamed('/login');
    }
  }

  Future<void> refreshProfile(UserModel user) async {
    currentUser.value = user;
    await _storage.saveUserData(jsonEncode(user.toJson()));
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

  Future<void> _saveAuthSession(AuthTokensModel data) async {
    await _storage.saveAccessToken(data.accessToken);
    await _storage.saveRefreshToken(data.refreshToken);
    await _storage.saveTokenExpiry(data.accessTokenExpiry);
    if (data.user != null) {
      currentUser.value = data.user;
      await _storage.saveUserData(jsonEncode(data.user!.toJson()));
    }
  }
}
