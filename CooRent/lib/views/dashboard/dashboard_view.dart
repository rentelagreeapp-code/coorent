import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:coorent/controllers/auth_controller.dart';
import 'package:coorent/controllers/dashboard_controller.dart';
import 'package:coorent/controllers/map_controller.dart';
import 'package:coorent/controllers/profile_controller.dart';
import 'package:coorent/views/dashboard/equipment_detail_view.dart';

class DashboardView extends StatelessWidget {
  DashboardView({super.key});

  final DashboardController _dashboardController = Get.find<DashboardController>();
  final MapController _mapController = Get.find<MapController>();
  final AuthController _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.agriculture, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text(
              'CooRent',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => Get.to(() => const NotificationsView()), // Navigate to dedicated Notifications screen
          ),
          Obx(() => GestureDetector(
                onTap: () => _dashboardController.changeTab(2), // Move to Profile
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _authController.currentUser.value?.name.isNotEmpty == true
                          ? _authController.currentUser.value!.name.substring(0, 1).toUpperCase()
                          : 'U',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )),
        ],
        elevation: 0,
      ),
      body: Obx(() {
        switch (_dashboardController.selectedTab.value) {
          case 0:
            return _buildHomeTab(context);
          case 1:
            return const BookingsTab();
          case 2:
            return const ProfileTab();
          default:
            return _buildHomeTab(context);
        }
      }),
      bottomNavigationBar: Obx(() => NavigationBar(
            selectedIndex: _dashboardController.selectedTab.value,
            onDestinationSelected: _dashboardController.changeTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_outline),
                selectedIcon: Icon(Icons.bookmark),
                label: 'My Bookings',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          )),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return Column(
      children: [
        // Top Part - Rental Services Categories
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rental Services',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed('/supplier-dashboard');
                    },
                    icon: const Icon(Icons.business_center_rounded, size: 14),
                    label: const Text(
                      'Switch as Supplier',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() => SizedBox(
                    height: 95,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _dashboardController.services.length,
                      itemBuilder: (context, index) {
                        final service = _dashboardController.services[index];
                        final isSelected = _mapController.selectedCategory.value.toLowerCase() == service.name.toLowerCase();

                        return Container(
                          width: 90,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.indigo[50] : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? Colors.indigo : Colors.transparent,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              _mapController.toggleCategory(service.name);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (service.imageUrl.isNotEmpty)
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Image.network(
                                      service.imageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                Text(
                                  service.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: isSelected ? Colors.indigo[900] : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )),
            ],
          ),
        ),
        
        // Bottom Part - Map view, Place search, drag sheet list, details popup
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              // Interactive FlutterMap
              Obx(() => fm.FlutterMap(
                    mapController: _mapController.fmMapController,
                    options: fm.MapOptions(
                      initialCenter: _mapController.currentPosition.value,
                      initialZoom: 12.0,
                      onPositionChanged: (position, hasGesture) {
                        _mapController.updateVisibleEquipments(position.bounds);
                        _mapController.mapRotation.value = _mapController.fmMapController.camera.rotation;
                      },
                    ),
                    children: [
                      fm.TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.coorent.coorent',
                      ),
                      // User Current Location Dot
                      fm.MarkerLayer(
                        markers: [
                          fm.Marker(
                            point: _mapController.currentPosition.value,
                            width: 24,
                            height: 24,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.indigo.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.indigo,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Clustered rental service markers
                      MarkerClusterLayerWidget(
                        options: MarkerClusterLayerOptions(
                          maxClusterRadius: 45,
                          size: const Size(40, 40),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(50),
                          markers: _mapController.mapMarkers.toList(),
                          builder: (context, markers) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  markers.length.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )),

              // Compass Overlay (North, South, East, West Direction Indicator)
              Positioned(
                top: 80,
                right: 16,
                child: Obx(() {
                  final rotationRad = _mapController.mapRotation.value * (3.141592653589793 / 180.0);
                  return GestureDetector(
                    onTap: _mapController.resetRotation,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                        ],
                        border: Border.all(color: Colors.indigo.withOpacity(0.2), width: 1.5),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 2,
                            child: Text('N', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.red[700])),
                          ),
                          const Positioned(
                            bottom: 2,
                            child: Text('S', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ),
                          const Positioned(
                            right: 4,
                            child: Text('E', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ),
                          const Positioned(
                            left: 4,
                            child: Text('W', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ),
                          Transform.rotate(
                            angle: -rotationRad,
                            child: const Icon(
                              Icons.navigation_rounded,
                              size: 18,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              // Place search card input floating on Map
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.indigo),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            textInputAction: TextInputAction.search,
                            onSubmitted: (val) {
                              _mapController.searchPlace(val);
                            },
                            decoration: InputDecoration(
                              hintText: 'Search by place / city...',
                              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Obx(() {
                          if (_mapController.searchQuery.value.isNotEmpty) {
                            return IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _mapController.clearSearch();
                              },
                            );
                          }
                          return const SizedBox();
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              // Selected Marker Details Popup Card Overlay
              Obx(() {
                final selected = _mapController.selectedEquipment.value;
                if (selected == null) return const SizedBox();
                
                final dist = _mapController.calculateDistance(selected.latitude, selected.longitude);
                final imgUrl = selected.equipmentImages.isNotEmpty ? selected.equipmentImages.first : '';

                return Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      onTap: () {
                        final matched = _dashboardController.services.firstWhereOrNull((s) => s.name.toLowerCase() == selected.ownerName.toLowerCase());
                        Get.to(() => EquipmentDetailView(
                              item: selected,
                              categoryName: widgetNameForCategory(selected.categoryId),
                              categoryImageUrl: matched?.imageUrl,
                            ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[100],
                                child: imgUrl.isNotEmpty
                                    ? Image.network(imgUrl, fit: BoxFit.cover)
                                    : const Icon(Icons.agriculture_rounded, size: 30, color: Colors.indigo),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          selected.equipmentName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close_rounded, size: 18),
                                        onPressed: () {
                                          _mapController.selectedEquipment.value = null;
                                          _mapController.highlightedEquipmentId.value = '';
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Provider: ${selected.ownerName}',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selected.price,
                                    style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 10, color: Colors.orange),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          selected.locationName.isNotEmpty ? selected.locationName : 'Unknown',
                                          style: TextStyle(color: Colors.grey[500], fontSize: 10),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${dist.toStringAsFixed(1)} km',
                                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Recenter location button
              Obx(() {
                final selected = _mapController.selectedEquipment.value;
                return Positioned(
                  bottom: selected != null ? 130 : 16,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _mapController.recenterMap,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    child: const Icon(Icons.my_location),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  String widgetNameForCategory(String categoryId) {
    // Helper to resolve category title by categoryId
    return 'Equipment';
  }
}

// Dummy Subviews for other navigation tabs to avoid compile issues
class BookingsTab extends StatelessWidget {
  const BookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Bookings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildBookingCard(context, 'BK-1089', 'Tractor Rental (John Deere)', 'June 28, 2026', 'Confirmed', '₹4,500'),
                _buildBookingCard(context, 'BK-2034', 'Labor Service (3 workers)', 'July 02, 2026', 'Pending', '₹2,400'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, String id, String title, String date, String status, String cost) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'Confirmed' ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status == 'Confirmed' ? Colors.green : Colors.amber[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date: $date', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                Text('Cost: $cost', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildNotificationItem(
          context,
          'Booking Confirmed',
          'Your booking BK-1089 for Tractor Rental has been approved by the provider.',
          '10 mins ago',
        ),
        _buildNotificationItem(
          context,
          'Promo Code Available',
          'Use code HARVEST10 to get 10% off on all Equipment Rentals.',
          '2 hours ago',
        ),
      ],
    );
  }

  Widget _buildNotificationItem(BuildContext context, String title, String desc, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(desc),
            const SizedBox(height: 6),
            Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final AuthController _authController = Get.find<AuthController>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = _authController.currentUser.value?.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Profile'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.trim().isNotEmpty) {
                  final profileController = Get.find<ProfileController>();
                  final navigator = Navigator.of(context);
                  await profileController.updateProfile(_nameController.text.trim());
                  navigator.pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                _authController.currentUser.value?.name.isNotEmpty == true
                    ? _authController.currentUser.value!.name.substring(0, 1).toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Obx(() => Text(
                _authController.currentUser.value?.name ?? 'Guest User',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              )),
          const SizedBox(height: 6),
          Obx(() => Text(
                '+91 ${_authController.currentUser.value?.mobileNumber ?? ''}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              )),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showEditProfileDialog(context),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _authController.logoutUser(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red,
              elevation: 0,
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts & Notifications'),
      ),
      body: const NotificationsTab(),
    );
  }
}
