import 'package:get/get.dart';

class BookingItem {
  final String id;
  final String serviceName;
  final String date;
  final String status;
  final String cost;

  BookingItem({required this.id, required this.serviceName, required this.date, required this.status, required this.cost});
}

class BookingController extends GetxController {
  var bookings = <BookingItem>[
    BookingItem(id: 'BK-1089', serviceName: 'Tractor Rental (John Deere)', date: 'June 28, 2026', status: 'Confirmed', cost: '₹4,500'),
    BookingItem(id: 'BK-2034', serviceName: 'Labor Service (3 workers)', date: 'July 02, 2026', status: 'Pending', cost: '₹2,400'),
  ].obs;
}
