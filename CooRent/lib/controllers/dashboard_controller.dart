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

  final List<ServiceItem> _fallbackServices = [
    ServiceItem(name: 'Tractor Rental', icon: Icons.agriculture, color: Colors.blueAccent, imageUrl: 'https://wydzxchvnkwpucmgomdz.supabase.co/storage/v1/object/public/coorent/Gemini_Generated_Image_pfpns2pfpns2pfpn-removebg-preview%20(1).png'),
    ServiceItem(name: 'Harvester Rental', icon: Icons.brightness_auto, color: Colors.indigoAccent, imageUrl: 'https://pngimg.com/uploads/combine_harvester/combine_harvester_PNG37.png'),
    ServiceItem(name: 'Equipment Rental', icon: Icons.build, color: Colors.purpleAccent, imageUrl: 'https://pngimg.com/uploads/plow/plow_PNG5.png'),
    ServiceItem(name: 'Transport', icon: Icons.local_shipping, color: Colors.deepPurpleAccent, imageUrl: 'https://pngimg.com/uploads/tractor/tractor_PNG16281.png'),
    ServiceItem(name: 'Seeds', icon: Icons.spa, color: Colors.amber, imageUrl: 'https://cdn-icons-png.flaticon.com/512/4115/4115160.png'),
    ServiceItem(name: 'Labor', icon: Icons.people, color: Colors.cyan, imageUrl: 'https://cdn-icons-png.flaticon.com/512/1792/1792823.png'),
  ];

  @override
  void onInit() {
    super.onInit();
    // Start with fallback/default services
    services.assignAll(_fallbackServices);
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

