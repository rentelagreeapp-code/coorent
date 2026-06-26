import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coorent/controllers/booking_controller.dart';

class ServicesView extends StatefulWidget {
  const ServicesView({super.key});

  @override
  State<ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends State<ServicesView> {
  final BookingController _bookingController = Get.find<BookingController>();
  late String serviceName;

  @override
  void initState() {
    super.initState();
    serviceName = Get.arguments ?? 'Rental Services';
    _bookingController.fetchServicesByCategory(serviceName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serviceName),
      ),
      body: Obx(() {
        if (_bookingController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_bookingController.servicesList.isEmpty) {
          return const Center(child: Text('No services available in this category.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _bookingController.servicesList.length,
          itemBuilder: (context, index) {
            final item = _bookingController.servicesList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        image: item.imageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(item.imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: item.imageUrl.isEmpty
                          ? Icon(
                              Icons.agriculture_rounded,
                              size: 40,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.priceDetails,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Get.snackbar(
                                    'Booking Initiated', 
                                    'Thank you for requesting this rental service', 
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.indigo,
                                    colorText: Colors.white
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Book Now'),
                              ),
                            ],
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
      }),
    );
  }
}
