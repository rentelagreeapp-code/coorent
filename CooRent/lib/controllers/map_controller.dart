import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:coorent/repositories/booking_repository.dart';
import 'package:coorent/models/equipment_model.dart';
import 'package:coorent/models/rental_service_model.dart';

class MapController extends GetxController {
  final fm.MapController fmMapController = fm.MapController();
  final BookingRepository _bookingRepository = Get.find<BookingRepository>();

  final LatLng initialPosition = const LatLng(28.6139, 77.2090);
  
  var currentPosition = const LatLng(28.6139, 77.2090).obs;
  var currentCity = 'New Delhi'.obs;
  var isLoadingRentals = false.obs;
  
  // Loaded equipments list from DB
  var rentalItems = <EquipmentModel>[].obs;
  
  // Only equipments visible in map viewport bounds
  var visibleEquipments = <EquipmentModel>[].obs;
  
  // Custom marker instances
  var mapMarkers = <fm.Marker>[].obs;

  // Selected filters
  var selectedCategory = ''.obs;
  var searchQuery = ''.obs;

  // Selection & Highlight synchronization
  var highlightedEquipmentId = ''.obs;
  var selectedEquipment = Rxn<EquipmentModel>();
  var mapRotation = 0.0.obs;

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
      fmMapController.move(currentPosition.value, 13.5);
      fetchCityName(position.latitude, position.longitude);
      loadRentals();
    } catch (e) {
      loadRentals();
    }
  }

  Future<void> fetchCityName(double lat, double lng) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': lng,
          'zoom': 10,
          'addressdetails': 1,
        },
        options: Options(headers: {'User-Agent': 'CooRentApp/1.0.0'}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final address = response.data['address'];
        if (address != null) {
          currentCity.value = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['suburb'] ??
              address['county'] ??
              'Unknown City';
        }
      }
    } catch (e) {
      debugPrint('Error resolving city: $e');
    }
  }

  Future<void> searchPlace(String query) async {
    if (query.trim().isEmpty) return;
    isLoadingRentals.value = true;
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 1,
        },
        options: Options(headers: {'User-Agent': 'CooRentApp/1.0.0'}),
      );
      if (response.statusCode == 200 && response.data != null && (response.data as List).isNotEmpty) {
        final first = response.data[0];
        final lat = double.parse(first['lat']);
        final lon = double.parse(first['lon']);
        final LatLng target = LatLng(lat, lon);
        
        currentPosition.value = target;
        currentCity.value = query;
        searchQuery.value = query;
        fmMapController.move(target, 13.0);
        
        await loadRentals(locationName: query);
      } else {
        Get.snackbar('Location Search', 'Place not found.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orangeAccent);
      }
    } catch (e) {
      debugPrint('Error searching location: $e');
    } finally {
      isLoadingRentals.value = false;
    }
  }

  Future<void> loadRentals({String? categoryName, String? locationName}) async {
    isLoadingRentals.value = true;
    try {
      String? categoryGuid;
      
      // Resolve categoryGuid if filtering by categoryName
      final filterCat = categoryName ?? selectedCategory.value;
      if (filterCat.isNotEmpty) {
        final List<RentalServiceModel> masterServices = await _bookingRepository.getAllServices();
        final matched = masterServices.firstWhereOrNull((s) => s.categoryName.toLowerCase() == filterCat.toLowerCase());
        if (matched != null) {
          categoryGuid = matched.categoryId;
        }
      }

      final filterLoc = locationName ?? searchQuery.value;
      final List<EquipmentModel> allEquipments = await _bookingRepository.getAllEquipments(
        categoryId: categoryGuid,
        locationName: filterLoc,
      );

      final List<fm.Marker> markersList = [];

      for (int i = 0; i < allEquipments.length; i++) {
        final item = allEquipments[i];
        
        markersList.add(
          fm.Marker(
            point: LatLng(item.latitude, item.longitude),
            width: 90,
            height: 90,
            child: GestureDetector(
              onTap: () {
                selectedEquipment.value = item;
                highlightedEquipmentId.value = item.id;
              },
              child: Obx(() {
                final isHighlighted = highlightedEquipmentId.value == item.id;
                final imgUrl = item.equipmentImages.isNotEmpty ? item.equipmentImages.first : '';

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Price tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isHighlighted ? Colors.orangeAccent : Colors.indigo,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                        ],
                      ),
                      child: Text(
                        item.price.split(' ')[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Image pin container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isHighlighted ? 52 : 44,
                      height: isHighlighted ? 52 : 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isHighlighted ? Colors.orangeAccent : Colors.indigo,
                          width: isHighlighted ? 3.5 : 2.5,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
                        ],
                      ),
                      child: ClipOval(
                        child: imgUrl.isNotEmpty
                            ? Image.network(
                                imgUrl,
                                fit: BoxFit.cover,
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
                );
              }),
            ),
          ),
        );
      }

      rentalItems.assignAll(allEquipments);
      mapMarkers.assignAll(markersList);
      updateVisibleEquipments(fmMapController.camera.visibleBounds);
    } catch (e) {
      debugPrint('Error loading rentals: $e');
    } finally {
      isLoadingRentals.value = false;
    }
  }

  Future<String> getCityNameFromCoords(double lat, double lng) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': lng,
          'zoom': 10,
          'addressdetails': 1,
        },
        options: Options(headers: {'User-Agent': 'CooRentApp/1.0.0'}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final address = response.data['address'];
        if (address != null) {
          return address['city'] ??
              address['town'] ??
              address['village'] ??
              address['suburb'] ??
              address['county'] ??
              'Unknown City';
        }
      }
    } catch (e) {
      debugPrint('Error getting city name from coords: $e');
    }
    return 'Selected Location';
  }

  void updateVisibleEquipments(fm.LatLngBounds? bounds) {
    if (bounds == null) {
      visibleEquipments.assignAll(rentalItems);
      return;
    }
    final filtered = rentalItems.where((eq) {
      return bounds.contains(LatLng(eq.latitude, eq.longitude));
    }).toList();
    visibleEquipments.assignAll(filtered);
  }

  double calculateDistance(double lat, double lng) {
    return Geolocator.distanceBetween(
          currentPosition.value.latitude,
          currentPosition.value.longitude,
          lat,
          lng,
        ) / 1000;
  }

  void selectEquipment(EquipmentModel item) {
    selectedEquipment.value = item;
    highlightedEquipmentId.value = item.id;
    fmMapController.move(LatLng(item.latitude, item.longitude), 13.5);
  }

  void toggleCategory(String category) {
    if (selectedCategory.value == category) {
      selectedCategory.value = '';
    } else {
      selectedCategory.value = category;
    }
    loadRentals();
  }

  void clearSearch() {
    searchQuery.value = '';
    loadRentals();
  }

  void recenterMap() {
    fmMapController.move(currentPosition.value, 13.5);
  }
}
