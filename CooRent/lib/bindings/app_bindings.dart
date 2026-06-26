import 'package:get/get.dart';
import 'package:coorent/core/api/api_client.dart';
import 'package:coorent/repositories/auth_repository.dart';
import 'package:coorent/repositories/user_repository.dart';
import 'package:coorent/controllers/auth_controller.dart';
import 'package:coorent/controllers/dashboard_controller.dart';
import 'package:coorent/controllers/profile_controller.dart';
import 'package:coorent/controllers/booking_controller.dart';
import 'package:coorent/controllers/map_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Core API Client
    final apiClient = ApiClient();
    Get.put<ApiClient>(apiClient, permanent: true);

    // Repositories
    final authRepository = AuthRepository(apiClient);
    final userRepository = UserRepository(apiClient);
    Get.put<AuthRepository>(authRepository, permanent: true);
    Get.put<UserRepository>(userRepository, permanent: true);

    // Controllers
    Get.put<AuthController>(AuthController(authRepository), permanent: true);
    
    // Lazy initialized views controllers
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<ProfileController>(() => ProfileController(userRepository));
    Get.lazyPut<BookingController>(() => BookingController());
    Get.lazyPut<MapController>(() => MapController());
  }
}
