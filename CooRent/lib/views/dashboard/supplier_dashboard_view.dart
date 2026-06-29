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
  final _customCategoryController = TextEditingController();
  bool _isCustomCategory = false;

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
    _customCategoryController.dispose();

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
      // 1. Fetch RentalServices (Master Data)
      final serviceList = await _bookingRepository.getAllServices();
      services.assignAll(serviceList);

      // Extract unique category names
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

      // 2. Fetch Equipments
      final equipmentList = await _bookingRepository.getAllEquipments();
      equipments.assignAll(equipmentList);

    } catch (e) {
      Get.snackbar('Error', 'Failed to load master data: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _addService() async {
    if (!_serviceFormKey.currentState!.validate()) return;

    final category = _isCustomCategory
        ? _customCategoryController.text.trim()
        : _selectedCategory ?? 'Other';

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

    // Link categoryId GUID dynamically from master category list
    String categoryGuid = '00000000-0000-0000-0000-000000000000';
    if (!_isCustomCategory && _selectedCategory != null) {
      final matched = services.firstWhereOrNull((s) => s.categoryName == _selectedCategory);
      if (matched != null) {
        categoryGuid = matched.categoryId;
      }
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
      Get.snackbar('Success', 'Rental service record added to Equipments successfully!',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      
      _sTitleController.clear();
      _sDescriptionController.clear();
      _sPriceController.clear();
      _sImageUrlController.clear();
      _customCategoryController.clear();

      await loadAllData();
      await _mapController.loadRentals();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add service record: $e',
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

    // Split comma separated image URLs
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
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);

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
                            'Add Rental Service',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('New Category?', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Switch(
                            value: _isCustomCategory,
                            onChanged: (val) {
                              setSheetState(() {
                                _isCustomCategory = val;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _isCustomCategory
                          ? TextFormField(
                              controller: _customCategoryController,
                              decoration: const InputDecoration(
                                labelText: 'Category Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'Enter category' : null,
                            )
                          : Obx(() {
                              if (categories.isEmpty) return const Text('No categories loaded.');
                              return DropdownButtonFormField<String>(
                                value: _selectedCategory ?? categories.first,
                                items: categories
                                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                                    .toList(),
                                onChanged: (val) {
                                  setSheetState(() {
                                    _selectedCategory = val;
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Select Category',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.category_rounded),
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
                        ),
                        child: const Text('Add Service Listing', style: TextStyle(fontWeight: FontWeight.bold)),
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

                      // Category (from Master Data RentalServices table)
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

                      // Equipment Name
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

                      // Description
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

                      // Price
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

                      // Equipment Images (comma separated)
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

                      // Coordinates (Lat/Lng)
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
      appBar: AppBar(
        title: const Text(
          'Supplier Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: loadAllData,
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.indigo,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.indigo,
          tabs: const [
            Tab(icon: Icon(Icons.category_rounded), text: 'Rental Services'),
            Tab(icon: Icon(Icons.agriculture_rounded), text: 'Detailed Equipments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Rental Services Tab
          Obx(() {
            if (isLoading.value && services.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (services.isEmpty) {
              return const Center(child: Text('No rental services added yet.'));
            }
            return RefreshIndicator(
              onRefresh: loadAllData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final item = services[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(Icons.inventory_2_outlined, color: Colors.indigo[400]),
                      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Category: ${item.categoryName}\n${item.description}'),
                      trailing: Text(item.priceDetails, style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            );
          }),

          // 2. Detailed Equipments Tab
          Obx(() {
            if (isLoading.value && equipments.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (equipments.isEmpty) {
              return const Center(child: Text('No detailed equipments added yet.'));
            }
            return RefreshIndicator(
              onRefresh: loadAllData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: equipments.length,
                itemBuilder: (context, index) {
                  final item = equipments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[100],
                          child: item.equipmentImages.isNotEmpty
                              ? Image.network(
                                  item.equipmentImages.first,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                                )
                              : const Icon(Icons.image),
                        ),
                      ),
                      title: Text(item.equipmentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(item.description),
                      trailing: Text(item.price, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddServiceSheet();
          } else {
            _showAddEquipmentSheet();
          }
        },
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
