import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController extends GetxController {
  GoogleMapController? googleMapController;
  
  // Default coordinate set (e.g. New Delhi, India)
  final LatLng initialPosition = const LatLng(28.6139, 77.2090);
  
  var currentPosition = const LatLng(28.6139, 77.2090).obs;
  var markers = <Marker>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSampleEquipmentMarkers();
  }

  void onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
    recenterMap();
  }

  void recenterMap() {
    googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentPosition.value,
          zoom: 13.5,
        ),
      ),
    );
  }

  void _loadSampleEquipmentMarkers() {
    markers.addAll([
      Marker(
        markerId: const MarkerId('tractor_1'),
        position: const LatLng(28.6159, 77.2110),
        infoWindow: const InfoWindow(title: 'John Deere Tractor', snippet: 'Available - ₹800/hr'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
      Marker(
        markerId: const MarkerId('harvester_1'),
        position: const LatLng(28.6099, 77.2010),
        infoWindow: const InfoWindow(title: 'Combine Harvester', snippet: 'Available - ₹1500/hr'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    ]);
  }
}
