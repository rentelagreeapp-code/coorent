import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coorent/repositories/booking_repository.dart';

class ServiceItem {
  final String name;
  final IconData icon;
  final Color color;
  final String imageUrl;

  ServiceItem({required this.name, required this.icon, required this.color, required this.imageUrl});
}

class DashboardController extends GetxController {
  var selectedTab = 0.obs;
  var isLoading = false.obs;
  var services = <ServiceItem>[].obs;

  final Map<String, IconData> _categoryIcons = {
    'tractor rental': Icons.agriculture,
    'harvester rental': Icons.brightness_auto,
    'equipment rental': Icons.build,
    'transport': Icons.local_shipping,
    'seeds': Icons.spa,
    'labor': Icons.people,
  };

  final Map<String, Color> _categoryColors = {
    'tractor rental': Colors.blueAccent,
    'harvester rental': Colors.indigoAccent,
    'equipment rental': Colors.purpleAccent,
    'transport': Colors.deepPurpleAccent,
    'seeds': Colors.amber,
    'labor': Colors.cyan,
  };

  @override
  void onInit() {
    super.onInit();
    fetchCategoriesFromApi();
  }

  Future<void> fetchCategoriesFromApi() async {
    isLoading.value = true;
    try {
      final bookingRepository = Get.find<BookingRepository>();
      final list = await bookingRepository.getAllServices();
      
      if (list.isNotEmpty) {
        // Extract unique categories (case insensitive mapping)
        final seen = <String>{};
        final List<ServiceItem> fetched = [];
        
        for (var rawService in list) {
          final catNormalized = rawService.categoryName.trim();
          if (catNormalized.isEmpty) continue;
          
          final catLower = catNormalized.toLowerCase();
          if (!seen.contains(catLower)) {
            seen.add(catLower);
            
            // Map icon
            IconData icon = Icons.agriculture;
            for (var key in _categoryIcons.keys) {
              if (catLower.contains(key) || key.contains(catLower)) {
                icon = _categoryIcons[key]!;
                break;
              }
            }
            
            // Map color
            Color color = Colors.blueAccent;
            for (var key in _categoryColors.keys) {
              if (catLower.contains(key) || key.contains(catLower)) {
                color = _categoryColors[key]!;
                break;
              }
            }
            
            fetched.add(ServiceItem(
              name: catNormalized,
              icon: icon,
              color: color,
              imageUrl: rawService.imageUrl.isNotEmpty 
                  ? rawService.imageUrl 
                  : 'https://images.unsplash.com/photo-1592928302636-c83cf1e1c887?w=200',
            ));
          }
        }
        
        if (fetched.isNotEmpty) {
          services.assignAll(fetched);
        }
      }
    } catch (e) {
      // Fallback already assigned in onInit
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }
}

