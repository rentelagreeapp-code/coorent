import 'package:flutter/material.dart';
import 'package:coorent/models/equipment_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final List<String> images = widget.item.equipmentImages.isNotEmpty
        ? widget.item.equipmentImages
        : (widget.categoryImageUrl != null && widget.categoryImageUrl!.isNotEmpty ? [widget.categoryImageUrl!] : []);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Simple AppBar with Back button & title
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.indigo[800],
            foregroundColor: Colors.white,
            title: Text(widget.item.equipmentName),
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
                        widget.item.price,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    widget.item.equipmentName,
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
                    widget.item.description.isNotEmpty ? widget.item.description : 'No description provided.',
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
    );
  }
}
