import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coorent/controllers/map_controller.dart';
import 'package:coorent/models/rental_service_model.dart';
import 'package:coorent/repositories/booking_repository.dart';

class SupplierDashboardView extends StatefulWidget {
  const SupplierDashboardView({super.key});

  @override
  State<SupplierDashboardView> createState() => _SupplierDashboardViewState();
}

class _SupplierDashboardViewState extends State<SupplierDashboardView> {
  final BookingRepository _bookingRepository = Get.find<BookingRepository>();
  final MapController _mapController = Get.find<MapController>();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  String? _selectedCategory;
  final _customCategoryController = TextEditingController();
  bool _isCustomCategory = false;

  var isLoading = false.obs;
  var services = <RentalServiceModel>[].obs;
  var categories = <String>[].obs;

  @override
  void initState() {
    super.initState();
    loadMasterData();
    // Default coordinates to user's current GPS location
    _latController.text = _mapController.currentPosition.value.latitude.toString();
    _lngController.text = _mapController.currentPosition.value.longitude.toString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> loadMasterData() async {
    isLoading.value = true;
    try {
      final list = await _bookingRepository.getAllServices();
      services.assignAll(list);

      // Extract unique categories for master data drop-down options
      final uniqueCategories = list
          .map((item) => item.categoryName)
          .where((cat) => cat.isNotEmpty)
          .toSet()
          .toList();
      categories.assignAll(uniqueCategories);

      if (uniqueCategories.isNotEmpty) {
        _selectedCategory = uniqueCategories.first;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load master services: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _addService() async {
    if (!_formKey.currentState!.validate()) return;

    final category = _isCustomCategory
        ? _customCategoryController.text.trim()
        : _selectedCategory ?? 'Other';

    if (category.isEmpty) {
      Get.snackbar('Validation Error', 'Category cannot be empty',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    final double? lat = double.tryParse(_latController.text);
    final double? lng = double.tryParse(_lngController.text);

    final newService = RentalServiceModel(
      id: '',
      categoryName: category,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priceDetails: _priceController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : 'https://wydzxchvnkwpucmgomdz.supabase.co/storage/v1/object/public/coorent/Gemini_Generated_Image_pfpns2pfpns2pfpn-removebg-preview%20(1).png',
      latitude: lat,
      longitude: lng,
    );

    isLoading.value = true;
    try {
      await _bookingRepository.createService(newService);
      Get.back(); // Close modal sheet
      Get.snackbar('Success', 'Rental service added successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      
      // Clear form inputs
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _imageUrlController.clear();
      _customCategoryController.clear();

      // Refresh master data and map markers
      await loadMasterData();
      await _mapController.loadRentals();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add service: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _showAddServiceSheet() {
    // Refresh coordinates to latest position when opening sheet
    _latController.text = _mapController.currentPosition.value.latitude.toString();
    _lngController.text = _mapController.currentPosition.value.longitude.toString();

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
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add Rental Service',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Category Mode Switch
                      Row(
                        children: [
                          const Text(
                            'New Category?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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

                      // Category Dropdown / Textfield
                      _isCustomCategory
                          ? TextFormField(
                              controller: _customCategoryController,
                              decoration: const InputDecoration(
                                labelText: 'Category Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Enter category'
                                  : null,
                            )
                          : Obx(() {
                              if (categories.isEmpty) {
                                return const Text('No categories loaded.');
                              }
                              return DropdownButtonFormField<String>(
                                value: _selectedCategory ?? categories.first,
                                items: categories
                                    .map((cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(cat),
                                        ))
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

                      // Equipment Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Equipment / Listing Title',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title_rounded),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Enter title'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Enter description'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Price Details
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price Details (e.g. ₹2000 / Day)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_rupee_rounded),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Enter price'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Image URL
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.image_outlined),
                          hintText: 'Https://...',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Coordinates (Lat/Lng)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Latitude',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lngController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Longitude',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on_outlined),
                              ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add Service Listing',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
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
            onPressed: loadMasterData,
          )
        ],
      ),
      body: Obx(() {
        if (isLoading.value && services.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (services.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No service listings added yet.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first machine.',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: loadMasterData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final item = services[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[100],
                      child: item.imageUrl.isNotEmpty
                          ? Image.network(
                              item.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.agriculture_rounded,
                                color: Colors.indigo,
                              ),
                            )
                          : const Icon(
                              Icons.agriculture_rounded,
                              color: Colors.indigo,
                            ),
                    ),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        'Category: ${item.categoryName}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                  trailing: Text(
                    item.priceDetails,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceSheet,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
