import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coorent/controllers/map_controller.dart';
import 'package:coorent/models/rental_service_model.dart';
import 'package:coorent/models/equipment_model.dart';
import 'package:coorent/repositories/booking_repository.dart';
import 'package:coorent/controllers/auth_controller.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';

class SupplierDashboardView extends StatefulWidget {
  const SupplierDashboardView({super.key});

  @override
  State<SupplierDashboardView> createState() => _SupplierDashboardViewState();
}

class _SupplierDashboardViewState extends State<SupplierDashboardView> with SingleTickerProviderStateMixin {
  var suggestions = <RentalServiceModel>[].obs;
  var isLoadingSuggestions = false.obs;

  Future<void> fetchSuggestions(String categoryName) async {
    isLoadingSuggestions.value = true;
    try {
      final list = await _bookingRepository.getServicesByCategory(categoryName);
      suggestions.assignAll(list);
    } catch (e) {
      print('Error fetching suggestions: $e');
    } finally {
      isLoadingSuggestions.value = false;
    }
  }

  final BookingRepository _bookingRepository = Get.find<BookingRepository>();
  final MapController _mapController = Get.find<MapController>();
  final AuthController _authController = Get.find<AuthController>();

  double? _customServiceLat;
  double? _customServiceLng;
  final _customServiceCity = ''.obs;

  double? _customEquipmentLat;
  double? _customEquipmentLng;
  final _customEquipmentCity = ''.obs;

  int _currentServiceStep = 1;
  String _pricePeriod = 'Day';
  final _priceAmountController = TextEditingController();

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

  final ImagePicker _picker = ImagePicker();
  final _pickedPhotos = <File>[].obs;

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
    _priceAmountController.dispose();
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
  print("hit 1");
    if (_pickedPhotos.length < 2 || _pickedPhotos.length > 5) {
      Get.snackbar('Validation Error', 'Please upload between 2 and 5 photos.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    print("hit 2");
    final category = _selectedCategory ?? 'Other';

    if (category.isEmpty) {
      Get.snackbar('Validation Error', 'Category cannot be empty',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    print("hit 3");
    final double lat = _customServiceLat ?? _mapController.currentPosition.value.latitude;
    final double lng = _customServiceLng ?? _mapController.currentPosition.value.longitude;

    isLoading.value = true;
    try {
      final List<String> imageUrls = [];

      for (int i = 0; i < _pickedPhotos.length; i++) {
        final File file = _pickedPhotos[i];
        final bytes = await file.readAsBytes();
        
        img.Image? decoded = img.decodeImage(bytes);
        if (decoded == null) {
          throw Exception('Failed to decode image $i');
        }

        int quality = 80;
        List<int> compressed = img.encodeJpg(decoded, quality: quality);
        
        int width = decoded.width;
        int height = decoded.height;

        while (compressed.length > 102400 && quality > 10) {
          quality -= 15;
          if (width > 800) {
            width = (width * 0.8).toInt();
            height = (height * 0.8).toInt();
            final resized = img.copyResize(decoded, width: width, height: height);
            compressed = img.encodeJpg(resized, quality: quality);
          } else {
            compressed = img.encodeJpg(decoded, quality: quality);
          }
        }
        print("hit 4");
        final Uint8List uploadBytes = Uint8List.fromList(compressed);
        final String fileName = 'equip_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        print("hit 5");
        final dio = Dio();
        final uploadUrl = 'https://wydzxchvnkwpucmgomdz.supabase.co/storage/v1/object/coorent/$fileName';
        print("hit 6");
        final response = await dio.post(
          uploadUrl,
          data: uploadBytes,
          options: Options(
            headers: {
              'Content-Type': 'image/jpeg',
              'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind5ZHp4Y2h2bmt3cHVjbWdvbWR6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI3MDY3NDMsImV4cCI6MjA5ODI4Mjc0M30.e6mk7nWq6cgHK0f9m_tIhPy84PFDanPuNfKYIsjljgI',
              'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind5ZHp4Y2h2bmt3cHVjbWdvbWR6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI3MDY3NDMsImV4cCI6MjA5ODI4Mjc0M30.e6mk7nWq6cgHK0f9m_tIhPy84PFDanPuNfKYIsjljgI',
            },
          ),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          imageUrls.add('https://wydzxchvnkwpucmgomdz.supabase.co/storage/v1/object/public/coorent/$fileName');
        } else {
          throw Exception('Failed to upload image $i: status code ${response.statusCode}');
        }
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
        equipmentImages: imageUrls,
        locationName: _customServiceCity.value,
      );

      await _bookingRepository.createEquipment(newEquipment);
      Navigator.pop(context);
      Get.snackbar('Success', 'Rental item added successfully!',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.indigo, colorText: Colors.white);
      
      _sTitleController.clear();
      _sDescriptionController.clear();
      _sPriceController.clear();
      _pickedPhotos.clear();

      await loadAllData();
      await _mapController.loadRentals();
    } catch (e) {
      String errMsg = e.toString();
      if (e is DioException) {
        final resData = e.response?.data;
        print('DioException response: $resData');
        errMsg = 'Server returned error: ${e.response?.statusCode} - $resData';
      }
      Get.snackbar('Error', 'Failed to add rental item: $errMsg',
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

    final double lat = _customEquipmentLat ?? _mapController.currentPosition.value.latitude;
    final double lng = _customEquipmentLng ?? _mapController.currentPosition.value.longitude;

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
      locationName: _customEquipmentCity.value,
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
    _customServiceLat = _mapController.currentPosition.value.latitude;
    _customServiceLng = _mapController.currentPosition.value.longitude;
    _customServiceCity.value = _mapController.currentCity.value;

    final initialIdx = services.indexWhere((s) => s.categoryName == _selectedCategory);
    final pageController = PageController(
      initialPage: initialIdx >= 0 ? initialIdx : 0,
      viewportFraction: 0.35,
    );

    _currentServiceStep = 1;
    _pricePeriod = 'Day';
    _priceAmountController.clear();

    // Populate initial default category if available
    if (services.isNotEmpty && _selectedCategory == null) {
      _selectedCategory = services[initialIdx >= 0 ? initialIdx : 0].categoryName;
    }

    // Fetch initial suggestions from DB for the selected category
    if (_selectedCategory != null) {
      fetchSuggestions(_selectedCategory!);
    }

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
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Add Rental Item',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Step $_currentServiceStep of 3: ${_currentServiceStep == 1 ? "Choose Rental Item" : _currentServiceStep == 2 ? "Equipment Details" : "Pricing & Location"}',
                                style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Linear step indicator bar
                      Row(
                        children: List.generate(3, (idx) {
                          final stepIdx = idx + 1;
                          final isActive = stepIdx <= _currentServiceStep;
                          return Expanded(
                            child: Container(
                              height: 5,
                              margin: EdgeInsets.only(right: idx < 2 ? 6.0 : 0.0),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.indigo : Colors.grey[300],
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),

                      // STEP 1: CHOOSE RENTAL ITEM (Category)
                      if (_currentServiceStep == 1) ...[
                        const Text(
                          'Choose rental item',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          if (services.isEmpty) return const Center(child: Text('No categories loaded.'));
                          return SizedBox(
                            height: 130,
                            child: PageView.builder(
                              controller: pageController,
                              onPageChanged: (index) {
                                setSheetState(() {
                                  _selectedCategory = services[index].categoryName;
                                });
                                fetchSuggestions(_selectedCategory!);
                              },
                              itemCount: services.length,
                              itemBuilder: (context, index) {
                                final serviceItem = services[index];
                                final cat = serviceItem.categoryName;
                                final imgUrl = serviceItem.imageUrl;
                                final isSelected = cat == _selectedCategory;

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
                                      setSheetState(() {
                                        _selectedCategory = services[index].categoryName;
                                      });
                                      fetchSuggestions(_selectedCategory!);
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
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setSheetState(() {
                              _currentServiceStep = 2;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Next: Equipment details ', style: TextStyle(fontWeight: FontWeight.bold)),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ],

                      // STEP 2: EQUIPMENT DETAILS & DESCRIPTION WITH SUGGESTIONS FROM DATABASE
                      if (_currentServiceStep == 2) ...[
                        Obx(() {
                          if (isLoadingSuggestions.value) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.indigo),
                                ),
                              ),
                            );
                          }
                          if (suggestions.isEmpty) return const SizedBox();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Suggested Templates:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 38,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: suggestions.length,
                                  itemBuilder: (context, index) {
                                    final sug = suggestions[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: ActionChip(
                                        label: Text(sug.title, style: const TextStyle(fontSize: 12)),
                                        backgroundColor: Colors.indigo[50],
                                        onPressed: () {
                                          setSheetState(() {
                                            _sTitleController.text = sug.title;
                                            _sDescriptionController.text = sug.description;
                                            
                                            // Prepopulate split price
                                            String price = sug.priceDetails.replaceAll('₹', '').trim();
                                            if (price.contains('/')) {
                                              var parts = price.split('/');
                                              _priceAmountController.text = parts[0].trim();
                                              String period = parts[1].trim().toLowerCase();
                                              if (period.contains('day')) {
                                                _pricePeriod = 'Day';
                                              } else if (period.contains('hour') || period.contains('hr')) {
                                                _pricePeriod = 'Hour';
                                              }
                                            } else {
                                              _priceAmountController.text = price;
                                            }
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }),
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
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setSheetState(() {
                                    _currentServiceStep = 1;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_sTitleController.text.trim().isEmpty || _sDescriptionController.text.trim().isEmpty) {
                                    Get.snackbar(
                                      'Validation Error',
                                      'Please fill in title and description',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.orange,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }
                                  setSheetState(() {
                                    _currentServiceStep = 3;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Next ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // STEP 3: PRICE DETAILS (Hour or Day), UPLOAD PHOTOS & DETECTED CITY
                      if (_currentServiceStep == 3) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _priceAmountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Price Amount (₹)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.currency_rupee_rounded),
                                ),
                                validator: (val) => val == null || val.isEmpty ? 'Enter amount' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                value: _pricePeriod,
                                items: const [
                                  DropdownMenuItem(value: 'Hour', child: Text('Hour')),
                                  DropdownMenuItem(value: 'Day', child: Text('Day')),
                                ],
                                onChanged: (val) {
                                  setSheetState(() {
                                    _pricePeriod = val ?? 'Day';
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Period',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Upload Equipment Photos (Select 2 to 5 images)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          return SizedBox(
                            height: 90,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _pickedPhotos.length + 1,
                              itemBuilder: (context, index) {
                                if (index == _pickedPhotos.length) {
                                  return GestureDetector(
                                    onTap: () async {
                                      if (_pickedPhotos.length >= 5) {
                                        Get.snackbar('Limit Reached', 'You can upload maximum 5 photos',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.orange,
                                            colorText: Colors.white);
                                        return;
                                      }
                                      final XFile? file = await _picker.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (file != null) {
                                        _pickedPhotos.add(File(file.path));
                                      }
                                    },
                                    child: Container(
                                      width: 80,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: const Icon(Icons.add_a_photo_outlined, size: 28, color: Colors.indigo),
                                    ),
                                  );
                                }

                                final File imageFile = _pickedPhotos[index];
                                return Stack(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      margin: const EdgeInsets.only(right: 8, top: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: FileImage(imageFile),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 2,
                                      child: GestureDetector(
                                        onTap: () {
                                          _pickedPhotos.removeAt(index);
                                        },
                                        child: const CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Colors.red,
                                          child: Icon(Icons.close, size: 12, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        Obx(() => TextFormField(
                          key: ValueKey(_customServiceCity.value),
                          initialValue: _customServiceCity.value,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Detected City',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.location_city_rounded),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.map_rounded, color: Colors.indigo),
                              onPressed: () {
                                _selectLocationOnMap(
                                  context: context,
                                  initialLat: _customServiceLat ?? _mapController.currentPosition.value.latitude,
                                  initialLng: _customServiceLng ?? _mapController.currentPosition.value.longitude,
                                  onLocationSelected: (lat, lng) async {
                                    _customServiceLat = lat;
                                    _customServiceLng = lng;
                                    _customServiceCity.value = 'Loading location...';
                                    final city = await _mapController.getCityNameFromCoords(lat, lng);
                                    _customServiceCity.value = city;
                                    setSheetState(() {});
                                  },
                                );
                              },
                            ),
                          ),
                        )),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setSheetState(() {
                                    _currentServiceStep = 2;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final amt = _priceAmountController.text.trim();
                                  if (amt.isEmpty) {
                                    Get.snackbar('Validation Error', 'Please enter a price amount',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.orange,
                                        colorText: Colors.white);
                                    return;
                                  }
                                  _sPriceController.text = '₹$amt / $_pricePeriod';
                                  _addService();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Add Rental Item', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
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
    _customEquipmentLat = _mapController.currentPosition.value.latitude;
    _customEquipmentLng = _mapController.currentPosition.value.longitude;
    _customEquipmentCity.value = _mapController.currentCity.value;

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
                      Obx(() => TextFormField(
                        key: ValueKey(_customEquipmentCity.value),
                        initialValue: _customEquipmentCity.value,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Location (Detected City)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.location_city_rounded),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.map_rounded, color: Colors.indigo),
                            onPressed: () {
                              _selectLocationOnMap(
                                context: context,
                                initialLat: _customEquipmentLat ?? _mapController.currentPosition.value.latitude,
                                initialLng: _customEquipmentLng ?? _mapController.currentPosition.value.longitude,
                                onLocationSelected: (lat, lng) async {
                                  _customEquipmentLat = lat;
                                  _customEquipmentLng = lng;
                                  _customEquipmentCity.value = 'Loading location...';
                                  final city = await _mapController.getCityNameFromCoords(lat, lng);
                                  _customEquipmentCity.value = city;
                                  setSheetState(() {});
                                },
                              );
                            },
                          ),
                        ),
                      )),
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
                                      Obx(() => Text(
                                        _mapController.currentCity.value,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                                      )),
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
                              Obx(() {
                                if (equipments.isEmpty) {
                                  return const SizedBox();
                                }
                                return _buildStatItem('Total Rental Items', '${equipments.length}');
                              }),
                              _buildStatItem('Verification', 'Verified', icon: Icons.verified_user_outlined, color: Colors.greenAccent),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Obx(() {
          if (isLoading.value && equipments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (equipments.isEmpty) {
            return _buildEmptyState('Add YOUR first rental item', showButton: true);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text(
                  'Our Rental Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: loadAllData,
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: equipments.length,
                    itemBuilder: (context, index) {
                      final item = equipments[index];
                      final master = services.firstWhereOrNull((s) => s.categoryId == item.categoryId);
                      final catName = master?.categoryName ?? 'Other';
                      return _buildGridCard(item, catName, master?.imageUrl);
                    },
                  ),
                ),
              ),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddServiceSheet,
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Rental Item', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {IconData? icon, Color? color}) {
    final textColor = color ?? Colors.white;
    final iconColor = color ?? Colors.indigo[100];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13)),
            Text(label, style: TextStyle(color: color?.withOpacity(0.8) ?? Colors.indigo[100], fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, {bool showButton = false}) {
     return Center(
       child: Padding(
         padding: const EdgeInsets.all(24.0),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(Icons.layers_clear_rounded, size: 64, color: Colors.grey[400]),
             const SizedBox(height: 16),
             Text(
               message,
               style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.bold),
               textAlign: TextAlign.center,
             ),
             if (showButton) ...[
               const SizedBox(height: 24),
               ElevatedButton.icon(
                 onPressed: _showAddServiceSheet,
                 icon: const Icon(Icons.add_rounded),
                 label: const Text('Add YOUR first rental item', style: TextStyle(fontWeight: FontWeight.bold)),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.indigo,
                   foregroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 ),
               ),
             ],
           ],
         ),
       ),
     );
   }

  Widget _buildGridCard(EquipmentModel item, String catName, String? catImageUrl) {
    final imgUrl = item.equipmentImages.isNotEmpty ? item.equipmentImages.first : catImageUrl;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image top header
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: imgUrl != null && imgUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imgUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey[100],
              ),
              child: imgUrl == null || imgUrl.isEmpty
                  ? Center(child: Icon(Icons.agriculture_rounded, size: 40, color: Colors.indigo[200]))
                  : null,
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.equipmentName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  catName,
                  style: TextStyle(fontSize: 10, color: Colors.indigo[700], fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.price,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 10, color: Colors.orangeAccent),
                        const SizedBox(width: 1),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 45),
                          child: Text(
                            item.locationName.isNotEmpty ? item.locationName : 'Unknown',
                            style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(EquipmentModel item, String catName, String? catImageUrl) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: catImageUrl != null && catImageUrl.isNotEmpty
                    ? Image.network(
                        catImageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.agriculture_rounded,
                          size: 30,
                          color: Colors.indigo[700],
                        ),
                      )
                    : Icon(
                        Icons.agriculture_rounded,
                        size: 30,
                        color: Colors.indigo[700],
                      ),
              ),
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
                            item.locationName.isNotEmpty
                                ? item.locationName
                                : 'Unknown Location',
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

  void _selectLocationOnMap({
    required BuildContext context,
    required double initialLat,
    required double initialLng,
    required Function(double lat, double lng) onLocationSelected,
  }) {
    double tempLat = initialLat;
    double tempLng = initialLng;
    final fm.MapController mapController = fm.MapController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: SizedBox(
                height: 450,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.map_rounded, color: Colors.indigo),
                              SizedBox(width: 8),
                              Text(
                                'Tap to Select Location',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          fm.FlutterMap(
                            mapController: mapController,
                            options: fm.MapOptions(
                              initialCenter: LatLng(tempLat, tempLng),
                              initialZoom: 14.0,
                              onTap: (tapPosition, point) {
                                setState(() {
                                  tempLat = point.latitude;
                                  tempLng = point.longitude;
                                });
                              },
                            ),
                            children: [
                              fm.TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.coorent.coorent',
                              ),
                              fm.MarkerLayer(
                                markers: [
                                  fm.Marker(
                                    point: LatLng(tempLat, tempLng),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: FloatingActionButton(
                              mini: true,
                              onPressed: () {
                                mapController.move(
                                  LatLng(_mapController.currentPosition.value.latitude, _mapController.currentPosition.value.longitude),
                                  14.0,
                                );
                                setState(() {
                                  tempLat = _mapController.currentPosition.value.latitude;
                                  tempLng = _mapController.currentPosition.value.longitude;
                                });
                              },
                              backgroundColor: Colors.white,
                              child: const Icon(Icons.my_location, color: Colors.indigo),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              onLocationSelected(tempLat, tempLng);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Confirm Location'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
