import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceItem {
  final String name;
  final IconData icon;
  final Color color;

  ServiceItem({required this.name, required this.icon, required this.color});
}

class DashboardController extends GetxController {
  var selectedTab = 0.obs;

  final List<ServiceItem> services = [
    ServiceItem(name: 'Tractor Rental', icon: Icons.agriculture, color: Colors.blueAccent),
    ServiceItem(name: 'Harvester Rental', icon: Icons.brightness_auto, color: Colors.indigoAccent),
    ServiceItem(name: 'Equipment Rental', icon: Icons.build, color: Colors.purpleAccent),
    ServiceItem(name: 'Transport', icon: Icons.local_shipping, color: Colors.deepPurpleAccent),
    ServiceItem(name: 'Seeds', icon: Icons.spa, color: Colors.amber),
    ServiceItem(name: 'Labor', icon: Icons.people, color: Colors.cyan),
  ];

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
