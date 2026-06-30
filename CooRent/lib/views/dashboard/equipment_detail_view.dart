import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coorent/models/equipment_model.dart';
import 'package:coorent/repositories/booking_repository.dart';

class EquipmentDetailView extends StatefulWidget {
  final EquipmentModel item;
  final String categoryName;
  final String? categoryImageUrl;

  const EquipmentDetailView({
    Key? key,
    required this.item,
    required this.categoryName,
    this.categoryImageUrl,
  }) : super(key: key);

  @override
  State<EquipmentDetailView> createState() => _EquipmentDetailViewState();
}

class _EquipmentDetailViewState extends State<EquipmentDetailView> {
  late String _equipmentName;
  late String _description;
  late String _price;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _equipmentName = widget.item.equipmentName;
    _description = widget.item.description;
    _price = widget.item.price;
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Rental Item?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this listing? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // close dialog
              try {
                final repo = Get.find<BookingRepository>();
                await repo.deleteEquipment(widget.item.id);
                Get.back(result: true); // go back to supplier dashboard with delete signal!
                Get.snackbar('Success', 'Rental item deleted successfully!',
                    snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.indigo, colorText: Colors.white);
              } catch (e) {
                Get.snackbar('Error', 'Failed to delete rental item: $e',
                    snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final titleController = TextEditingController(text: _equipmentName);
    final descController = TextEditingController(text: _description);
    final priceController = TextEditingController(text: _price);

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Rental Item', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Equipment Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price Details',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty || priceController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Name and Price fields are required',
                    snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }

              Get.back(); // close dialog
              try {
                final repo = Get.find<BookingRepository>();
                final updated = EquipmentModel(
                  id: widget.item.id,
                  categoryId: widget.item.categoryId,
                  userId: widget.item.userId,
                  equipmentName: titleController.text.trim(),
                  description: descController.text.trim(),
                  price: priceController.text.trim(),
                  latitude: widget.item.latitude,
                  longitude: widget.item.longitude,
                  equipmentImages: widget.item.equipmentImages,
                  locationName: widget.item.locationName,
                );

                await repo.updateEquipment(widget.item.id, updated);
                
                setState(() {
                  _equipmentName = titleController.text.trim();
                  _description = descController.text.trim();
                  _price = priceController.text.trim();
                  _hasChanges = true;
                });

                Get.snackbar('Success', 'Rental item updated successfully!',
                    snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.indigo, colorText: Colors.white);
              } catch (e) {
                Get.snackbar('Error', 'Failed to update rental item: $e',
                    snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = widget.item.equipmentImages.isNotEmpty
        ? widget.item.equipmentImages
        : (widget.categoryImageUrl != null && widget.categoryImageUrl!.isNotEmpty ? [widget.categoryImageUrl!] : []);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: CustomScrollView(
          slivers: [
            // Simple AppBar with Back button & title
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.indigo[800],
              foregroundColor: Colors.white,
              title: Text(_equipmentName),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context, _hasChanges),
              ),
            ),
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Price row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.indigo[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.categoryName,
                            style: TextStyle(color: Colors.indigo[900], fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        Text(
                          _price,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      _equipmentName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    // Location details
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.orangeAccent),
                        const SizedBox(width: 4),
                        Text(
                          widget.item.locationName.isNotEmpty
                              ? widget.item.locationName
                              : 'Coordinates: [${widget.item.latitude.toStringAsFixed(4)}, ${widget.item.longitude.toStringAsFixed(4)}]',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Description Header
                    const Text(
                      'About this equipment',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    // Description Text
                    Text(
                      _description.isNotEmpty ? _description : 'No description provided.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    // Grid View of Photos
                    if (images.isNotEmpty) ...[
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text(
                        'Equipment Photos',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[200]!),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Image.network(
                                images[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.indigo[50],
                                    child: Icon(Icons.broken_image_rounded, color: Colors.indigo[200]),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Verification & Date row
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.greenAccent,
                            child: Icon(Icons.verified_user_rounded, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Verified Rental Item',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Ready to rent',
                                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: Row(
              children: [
                // Edit Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditDialog(context),
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit Listing', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Delete Button
                ElevatedButton(
                  onPressed: () => _confirmDelete(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red[200]!),
                    ),
                  ),
                  child: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
