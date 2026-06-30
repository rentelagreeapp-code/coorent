import 'package:flutter/material.dart';
import 'package:coorent/models/equipment_model.dart';

class EquipmentDetailView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final imgUrl = item.equipmentImages.isNotEmpty ? item.equipmentImages.first : categoryImageUrl;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Collapsible Image Header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.indigo[800],
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (imgUrl != null && imgUrl.isNotEmpty)
                    Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      color: Colors.indigo[50],
                      child: Icon(Icons.agriculture_rounded, size: 80, color: Colors.indigo[200]),
                    ),
                  // Dark bottom gradient overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ],
              ),
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
                          categoryName,
                          style: TextStyle(color: Colors.indigo[900], fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Text(
                        item.price,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    item.equipmentName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  // Location details
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.orangeAccent),
                      const SizedBox(width: 4),
                      Text(
                        item.locationName.isNotEmpty ? item.locationName : 'Coordinates: [${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)}]',
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
                    item.description.isNotEmpty ? item.description : 'No description provided.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                  ),
                  const SizedBox(height: 30),
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
