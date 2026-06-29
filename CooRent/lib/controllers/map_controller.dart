import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';

import 'package:geolocator/geolocator.dart';
import 'package:coorent/repositories/booking_repository.dart';
import 'package:coorent/models/rental_service_model.dart';

class MapController extends GetxController {
  final fm.MapController fmMapController = fm.MapController();
  final BookingRepository _bookingRepository = Get.find<BookingRepository>();

  // Default coordinate set (e.g. New Delhi, India)
  final LatLng initialPosition = const LatLng(28.6139, 77.2090);
  
  var currentPosition = const LatLng(28.6139, 77.2090).obs;
  var isLoadingRentals = false.obs;
  
  // Real active rentals loaded from API
  var rentalItems = <RentalServiceModel>[].obs;
  
  // Flutter map markers derived from rental items
  var mapMarkers = <fm.Marker>[].obs;

  @override
  void onInit() {
    super.onInit();
    determinePosition();
  }

  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      loadRentals();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        loadRentals();
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      loadRentals();
      return;
    } 

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentPosition.value = LatLng(position.latitude, position.longitude);
      
      // Move map view to the user's location
      fmMapController.move(currentPosition.value, 13.5);
      
      // Load nearby rentals from API
      loadRentals();
    } catch (e) {
      loadRentals();
    }
  }

  Future<void> loadRentals() async {
    isLoadingRentals.value = true;
    try {
      final List<RentalServiceModel> allRentals = await _bookingRepository.getAllServices();
      
      final List<fm.Marker> markersList = [];
      final List<RentalServiceModel> populatedRentals = [];

      for (int i = 0; i < allRentals.length; i++) {
        final item = allRentals[i];
        
        // If DB has no coordinates, assign sample nearby locations around currentPosition
        double lat = item.latitude ?? (currentPosition.value.latitude + (0.01 * (i % 3 - 1)) + (0.005 * (i % 2)));
        double lng = item.longitude ?? (currentPosition.value.longitude + (0.015 * (i % 2 - 1)) + (0.007 * (i % 3)));
        
        final rentalWithCoords = RentalServiceModel(
          id: item.id,
          categoryName: item.categoryName,
          title: item.title,
          description: item.description,
          priceDetails: item.priceDetails,
          imageUrl: item.imageUrl,
          latitude: lat,
          longitude: lng,
        );
        populatedRentals.add(rentalWithCoords);

        // Build a beautiful custom pin widget
        markersList.add(
          fm.Marker(
            point: LatLng(lat, lng),
            width: 80,
            height: 80,
            child: GestureDetector(
              onTap: () {
                // Open the existing details screen
                Get.toNamed('/equipment-details', arguments: item.id);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Price Tag Bubble
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      item.priceDetails.split(' ')[0], // Display short price (e.g. ₹2500)
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Avatar/Image Pin
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.indigo, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: ClipOval(
                      child: item.imageUrl.isNotEmpty
                          ? Image.network(
                              item.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.agriculture,
                                color: Colors.indigo,
                                size: 20,
                              ),
                            )
                          : const Icon(
                              Icons.agriculture,
                              color: Colors.indigo,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      rentalItems.assignAll(populatedRentals);
      mapMarkers.assignAll(markersList);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load nearby rental items: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[50],
        colorText: Colors.red[900],
      );
    } finally {
      isLoadingRentals.value = false;
    }
  }

  void recenterMap() {
    fmMapController.move(currentPosition.value, 13.5);
  }
}
