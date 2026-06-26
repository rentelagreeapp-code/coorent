import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceItem {
  final String name;
  final IconData icon;
  final Color color;
  final String imageUrl;

  ServiceItem({required this.name, required this.icon, required this.color, required this.imageUrl});
}

class DashboardController extends GetxController {
  var selectedTab = 0.obs;

  final List<ServiceItem> services = [
    ServiceItem(name: 'Tractor Rental', icon: Icons.agriculture, color: Colors.blueAccent, imageUrl: 'https://images.unsplash.com/photo-1592928302636-c83cf1e1c887?w=200'),
    ServiceItem(name: 'Harvester Rental', icon: Icons.brightness_auto, color: Colors.indigoAccent, imageUrl: 'https://images.unsplash.com/photo-1574382352842-1e967a505bfa?w=200'),
    ServiceItem(name: 'Equipment Rental', icon: Icons.build, color: Colors.purpleAccent, imageUrl: 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=200'),
    ServiceItem(name: 'Transport', icon: Icons.local_shipping, color: Colors.deepPurpleAccent, imageUrl: 'https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?w=200'),
    ServiceItem(name: 'Seeds', icon: Icons.spa, color: Colors.amber, imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=200'),
    ServiceItem(name: 'Labor', icon: Icons.people, color: Colors.cyan, imageUrl: 'https://images.unsplash.com/photo-1595974482597-4b8da8879bc5?w=200'),
  ];

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
