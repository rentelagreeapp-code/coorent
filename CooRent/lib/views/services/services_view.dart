import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServicesView extends StatelessWidget {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final String serviceName = Get.arguments ?? 'Rental Services';

    return Scaffold(
      appBar: AppBar(
        title: Text(serviceName),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.agriculture_rounded,
                      size: 40,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$serviceName Class ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Equipped with advanced GPS systems.',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '₹800 - 1500 / hr',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
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
      ),
    );
  }
}
