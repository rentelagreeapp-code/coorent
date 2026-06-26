import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:coorent/controllers/auth_controller.dart';
import 'package:coorent/controllers/dashboard_controller.dart';
import 'package:coorent/controllers/map_controller.dart';
import 'package:coorent/controllers/profile_controller.dart';

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
            onPressed: () => _dashboardController.changeTab(2), // Move to Notifications
          ),
          Obx(() => GestureDetector(
                onTap: () => _dashboardController.changeTab(3), // Move to Profile
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
            return const NotificationsTab();
          case 3:
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
                icon: Icon(Icons.notifications_none_rounded),
                selectedIcon: Icon(Icons.notifications_rounded),
                label: 'Alerts',
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
        // Top Half - Service Grid
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Rental Services',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: _dashboardController.services.length,
                    itemBuilder: (context, index) {
                      final service = _dashboardController.services[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Get.toNamed('/services', arguments: service.name);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: service.color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    service.icon,
                                    color: service.color,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    service.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Bottom Half - Google Maps
        Expanded(
          flex: 1,
          child: Stack(
            children: [
              Obx(() => GoogleMap(
                    onMapCreated: _mapController.onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _mapController.initialPosition,
                      zoom: 12.0,
                    ),
                    markers: _mapController.markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    compassEnabled: true,
                  )),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: _mapController.recenterMap,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
