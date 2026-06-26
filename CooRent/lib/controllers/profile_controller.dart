import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coorent/repositories/user_repository.dart';
import 'package:coorent/controllers/auth_controller.dart';
import 'package:coorent/models/user_model.dart';

class ProfileController extends GetxController {
  final UserRepository _userRepository;
  final AuthController _authController = Get.find<AuthController>();

  ProfileController(this._userRepository);

  var isLoading = false.obs;
  var userProfile = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    userProfile.value = _authController.currentUser.value;
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final profile = await _userRepository.getProfile();
      userProfile.value = profile;
      _authController.refreshProfile(profile);
    } catch (e) {
      // Fallback to locally cached user if offline
      userProfile.value = _authController.currentUser.value;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(String name) async {
    isLoading.value = true;
    try {
      final updated = await _userRepository.updateProfile(name);
      userProfile.value = updated;
      _authController.refreshProfile(updated);
      Get.back();
      Get.snackbar(
        'Success', 
        'Profile updated successfully', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
