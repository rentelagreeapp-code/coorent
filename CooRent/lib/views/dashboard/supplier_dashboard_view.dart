import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coorent/controllers/map_controller.dart';
import 'package:coorent/models/rental_service_model.dart';
import 'package:coorent/models/equipment_model.dart';
import 'package:coorent/repositories/booking_repository.dart';
import 'package:coorent/controllers/auth_controller.dart';

class SupplierDashboardView extends StatefulWidget {
  const SupplierDashboardView({super.key});

  @override
  State<SupplierDashboardView> createState() => _SupplierDashboardViewState();
}

class _SupplierDashboardViewState extends State<SupplierDashboardView> with SingleTickerProviderStateMixin {
  final BookingRepository _bookingRepository = Get.find<BookingRepository>();
  final MapController _mapController = Get.find<MapController>();
  final AuthController _authController = Get.find<AuthController>();

  late TabController _tabController;

  // Forms
  final _serviceFormKey = GlobalKey<FormState>();
  final _equipmentFormKey = GlobalKey<FormState>();

  // Service form controllers
  final _sTitleController = TextEditingController();
  final _sDescriptionController = TextEditingController();
  final _sPriceController = TextEditingController();
  final _sImageUrlController = TextEditingController();
  final _sLatController = TextEditingController();
  final _sLngController = TextEditingController();
  String? _selectedCategory;

  // Equipment form controllers
  final _eNameController = TextEditingController();
  final _eDescriptionController = TextEditingController();
  final _ePriceController = TextEditingController();
  final _eImagesController = TextEditingController(); // Comma-separated URLs
  final _eLatController = TextEditingController();
  final _eLngController = TextEditingController();
  RentalServiceModel? _eSelectedCategoryModel;

  var isLoading = false.obs;
  var services = <RentalServiceModel>[].obs;
  var categories = <String>[].obs;
  var equipments = <EquipmentModel>[].obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sTitleController.dispose();
    _sDescriptionController.dispose();
    _sPriceController.dispose();
    _sImageUrlController.dispose();
    _sLatController.dispose();
    _sLngController.dispose();

    _eNameController.dispose();
    _eDescriptionController.dispose();
    _ePriceController.dispose();
    _eImagesController.dispose();
    _eLatController.dispose();
    _eLngController.dispose();
    super.dispose();
  }

  Future<void> loadAllData() async {
    isLoading.value = true;
    try {
      final serviceList = await _bookingRepository.getAllServices();
      services.assignAll(serviceList);

      final uniqueCats = serviceList
          .map((item) => item.categoryName)
          .where((cat) => cat.isNotEmpty)
          .toSet()
          .toList();
      categories.assignAll(uniqueCats);

      if (uniqueCats.isNotEmpty) {
        _selectedCategory = uniqueCats.first;
      }
      if (serviceList.isNotEmpty) {
        _eSelectedCategoryModel = serviceList.first;
      }

      final String userId = _authController.currentUserId.value;
      if (userId.isNotEmpty) {
        final equipmentList = await _bookingRepository.getEquipmentsByUserId(userId);
        equipments.assignAll(equipmentList);
      } else {
        final equipmentList = await _bookingRepository.getAllEquipments();
        equipments.assignAll(equipmentList);
      }

    } catch (e) {
      Get.snackbar('Error', 'Failed to load master data: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _addService() async {
    if (!_serviceFormKey.currentState!.validate()) return;

    final category = _selectedCategory ?? 'Other';

    if (category.isEmpty) {
      Get.snackbar('Validation Error', 'Category cannot be empty',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final double lat = double.tryParse(_sLatController.text) ?? 0.0;
    final double lng = double.tryParse(_sLngController.text) ?? 0.0;

    final List<String> images = [];
    if (_sImageUrlController.text.trim().isNotEmpty) {
      images.add(_sImageUrlController.text.trim());
    } else {
      images.add('https://wydzxchvnkwpucmgomdz.supabase.co/storage/v1/object/public/coorent/Gemini_Generated_Image_pfpns2pfpns2pfpn-removebg-preview%20(1).png');
    }

    String categoryGuid = '00000000-0000-0000-0000-000000000000';
    final matched = services.firstWhereOrNull((s) => s.categoryName == _selectedCategory);
    if (matched != null) {
      categoryGuid = matched.categoryId;
    }

    final newEquipment = EquipmentModel(
      id: '',
      categoryId: categoryGuid,
      userId: _authController.currentUserId.value.isNotEmpty 
          ? _authController.currentUserId.value 
          : '00000000-0000-0000-0000-000000000000',
      equipmentName: _sTitleController.text.trim(),
      description: _sDescriptionController.text.trim(),
      price: _sPriceController.text.trim(),
      latitude: lat,
      longitude: lng,
      equipmentImages: images,
    );

    isLoading.value = true;
    try {
      await _bookingRepository.createEquipment(newEquipment);
      Navigator.pop(context);
      Get.snackbar('Success', 'Rental item added successfully!',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.indigo, colorText: Colors.white);
      
      _sTitleController.clear();
      _sDescriptionController.clear();
      _sPriceController.clear();
      _sImageUrlController.clear();

      await loadAllData();
      await _mapController.loadRentals();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add rental item: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _addEquipment() async {
    if (!_equipmentFormKey.currentState!.validate()) return;
    if (_eSelectedCategoryModel == null) {
      Get.snackbar('Validation Error', 'Please select a Category from Master Data',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final double lat = double.tryParse(_eLatController.text) ?? 0.0;
    final double lng = double.tryParse(_eLngController.text) ?? 0.0;

    final List<String> images = _eImagesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (images.isEmpty) {
      images.add('https://wydzxchvnkwpucmgomdz.supabase.co/storage/v1/object/public/coorent/Gemini_Generated_Image_pfpns2pfpns2pfpn-removebg-preview%20(1).png');
    }

    final newEquipment = EquipmentModel(
      id: '',
      categoryId: _eSelectedCategoryModel!.categoryId,
      userId: _authController.currentUserId.value.isNotEmpty 
          ? _authController.currentUserId.value 
          : '00000000-0000-0000-0000-000000000000',
      equipmentName: _eNameController.text.trim(),
      description: _eDescriptionController.text.trim(),
      price: _ePriceController.text.trim(),
      latitude: lat,
      longitude: lng,
      equipmentImages: images,
    );

    isLoading.value = true;
    try {
      await _bookingRepository.createEquipment(newEquipment);
      Navigator.pop(context);
      Get.snackbar('Success', 'Equipment listing added successfully!',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.indigo, colorText: Colors.white);

      _eNameController.clear();
      _eDescriptionController.clear();
      _ePriceController.clear();
      _eImagesController.clear();

      await loadAllData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add equipment: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _showAddServiceSheet() {
    _sLatController.text = _mapController.currentPosition.value.latitude.toString();
    _sLngController.text = _mapController.currentPosition.value.longitude.toString();

    final initialIdx = categories.indexOf(_selectedCategory ?? categories.first);
    final pageController = PageController(
      initialPage: initialIdx >= 0 ? initialIdx : 0,
      viewportFraction: 0.35,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _serviceFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add Rental Item',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Select Category (Swipe to Choose Center Item)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Obx(() {
                        if (categories.isEmpty) return const Center(child: Text('No categories loaded.'));
                        return SizedBox(
                          height: 130,
                          child: PageView.builder(
                            controller: pageController,
                            onPageChanged: (index) {
                              setSheetState(() {
                                _selectedCategory = categories[index];
                              });
                            },
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              final isSelected = cat == _selectedCategory;

                              // Map category names to illustrative network image URLs
                              String imgUrl = 'https://wydzxchvnkwpucmgomdz.supabase.co/storage/v1/object/public/coorent/Gemini_Generated_Image_pfpns2pfpns2pfpn-removebg-preview%20(1).png';
                              if (cat.toLowerCase().contains('tractor')) {
                                imgUrl = 'https://wydzxchvnkwpucmgomdz.supabase.co/storage/v1/object/public/coorent/Gemini_Generated_Image_pfpns2pfpns2pfpn-removebg-preview%20(1).png';
                              } else if (cat.toLowerCase().contains('jcb')) {
                                imgUrl = 'https://wydzxchvnkwpucmgomdz.supabase.co/storage/v1/object/public/coorent/Gemini_Generated_Image_5rrtf25rrtf25rrt-removebg-preview.png';
                              } else if (cat.toLowerCase().contains('car')) {
                                imgUrl = 'https://wydzxchvnkwpucmgomdz.supabase.co/storage/v1/object/public/coorent/Gemini_Generated_Image_5pxb2o5pxb2o5pxb-removebg-preview.png';
                              } else if (cat.toLowerCase().contains('drone')) {
                                imgUrl = 'https://wydzxchvnkwpucmgomdz.supabase.co/storage/v1/object/public/coorent/Gemini_Generated_Image_6hszwz6hszwz6hsz-removebg-preview.png';
                              }

                              return AnimatedScale(
                                scale: isSelected ? 1.18 : 0.82,
                                duration: const Duration(milliseconds: 250),
                                child: GestureDetector(
                                  onTap: () {
                                    pageController.animateToPage(
                                      index,
                                      duration: const Duration(milliseconds: 350),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.indigo[50] : Colors.grey[100],
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected ? Colors.indigo : Colors.grey[300]!,
                                            width: isSelected ? 2.5 : 1,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.indigo.withOpacity(0.2),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  )
                                                ]
                                              : [],
                                        ),
                                        child: Image.network(
                                          imgUrl,
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.agriculture_rounded,
                                              size: 32,
                                              color: isSelected ? Colors.indigo : Colors.grey[400],
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        cat,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? Colors.indigo[900] : Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _sTitleController,
                        decoration: const InputDecoration(
                          labelText: 'Equipment / Listing Title',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title_rounded),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Enter title' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _sDescriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Enter description' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _sPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Price Details (e.g. ₹2000 / Day)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_rupee_rounded),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Enter price' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _sImageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.image_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _sLatController,
                              decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _sLngController,
                              decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _addService,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Add Rental Item', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddEquipmentSheet() {
    _eLatController.text = _mapController.currentPosition.value.latitude.toString();
    _eLngController.text = _mapController.currentPosition.value.longitude.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _equipmentFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add Detailed Equipment',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        if (services.isEmpty) {
                          return const Text('Loading master categories list...', style: TextStyle(color: Colors.red));
                        }
                        return DropdownButtonFormField<RentalServiceModel>(
                          value: _eSelectedCategoryModel ?? services.first,
                          items: services
                              .map((model) => DropdownMenuItem(
                                    value: model,
                                    child: Text('${model.categoryName} - ${model.title}'),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setSheetState(() {
                              _eSelectedCategoryModel = val;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Master Category (Linked ID)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.link_rounded),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _eNameController,
                        decoration: const InputDecoration(
                          labelText: 'Equipment Name (e.g. Mahindra 575 DI)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.agriculture_rounded),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Enter equipment name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _eDescriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Detailed Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Enter description' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ePriceController,
                        decoration: const InputDecoration(
                          labelText: 'Pricing / Rental Cost',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_rupee_rounded),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Enter pricing details' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _eImagesController,
                        decoration: const InputDecoration(
                          labelText: 'Equipment Image URLs (comma separated)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.photo_library_outlined),
                          hintText: 'Url1, Url2, Url3',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _eLatController,
                              decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _eLngController,
                              decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _addEquipment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Add Equipment Listing', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Sliver app bar with Supplier Profile and location details
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              backgroundColor: Colors.indigo[800],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient overlay background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.indigo[900]!, Colors.indigo[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // Background design circle
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    // Main Supplier details column
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.indigo[100],
                                child: Text(
                                  _authController.currentUser.value?.name.substring(0, 1).toUpperCase() ?? 'S',
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.indigo[900]),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _authController.currentUser.value?.name ?? 'Farmer Supplier',
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.phone_iphone_rounded, size: 14, color: Colors.indigo[100]),
                                        const SizedBox(width: 4),
                                        Text(
                                          _authController.currentUser.value?.mobileNumber ?? 'Mobile Not Verified',
                                          style: TextStyle(fontSize: 13, color: Colors.indigo[50]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Glassmorphic Location & Address Container
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.my_location_rounded, color: Colors.orangeAccent, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Primary Supplying Hub',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      Obx(() {
                                        final double lat = _mapController.currentPosition.value.latitude;
                                        final double lng = _mapController.currentPosition.value.longitude;
                                        return Text(
                                          'AgriHub Center, coordinates: [${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}]',
                                          style: TextStyle(color: Colors.indigo[50], fontSize: 11),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Statistics banner
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(() => _buildStatItem('Active Items', '${equipments.length}', Icons.agriculture)),
                              _buildStatItem('Supplying Radius', '15 km', Icons.explore_outlined),
                              _buildStatItem('Verification', 'Verified', Icons.verified_user_outlined),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sliver persistent tab header
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.indigo[900],
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: Colors.indigo,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: const [
                    Tab(icon: Icon(Icons.list_alt_rounded), text: 'Active Services'),
                    Tab(icon: Icon(Icons.grid_view_rounded), text: 'Detail Items'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Active Services (Supplier's Equipments list)
            Obx(() {
              if (isLoading.value && equipments.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (equipments.isEmpty) {
                return _buildEmptyState('No active items listed. Tap + to begin.');
              }
              return RefreshIndicator(
                onRefresh: loadAllData,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: equipments.length,
                  itemBuilder: (context, index) {
                    final item = equipments[index];
                    final master = services.firstWhereOrNull((s) => s.categoryId == item.categoryId);
                    final catName = master?.categoryName ?? 'Other';

                    return _buildServiceCard(item, catName);
                  },
                ),
              );
            }),

            // Tab 2: Detailed Equipments grid-style list
            Obx(() {
              if (isLoading.value && equipments.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (equipments.isEmpty) {
                return _buildEmptyState('No detailed equipment items registered.');
              }
              return RefreshIndicator(
                onRefresh: loadAllData,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: equipments.length,
                  itemBuilder: (context, index) {
                    final item = equipments[index];
                    return _buildDetailCard(item);
                  },
                ),
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddServiceSheet();
          } else {
            _showAddEquipmentSheet();
          }
        },
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Rental Item', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.indigo[100]),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
            Text(label, style: TextStyle(color: Colors.indigo[100], fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_clear_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildServiceCard(EquipmentModel item, String catName) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.agriculture_rounded, size: 30, color: Colors.indigo[700]),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.equipmentName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      catName,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              item.price,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo[800], fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(EquipmentModel item) {
    final image = item.equipmentImages.isNotEmpty
        ? item.equipmentImages.first
        : 'https://wydzxchvnkwpucmgomdz.supabase.co/storage/v1/object/public/coorent/Gemini_Generated_Image_pfpns2pfpns2pfpn-removebg-preview%20(1).png';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: SizedBox(
              width: 110,
              height: 110,
              child: Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.image, color: Colors.grey[400]),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.equipmentName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.price,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 14),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: Colors.orangeAccent),
                          const SizedBox(width: 2),
                          Text(
                            '${item.latitude.toStringAsFixed(2)}, ${item.longitude.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Persistent Header Delegate for TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
