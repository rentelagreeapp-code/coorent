import 'package:get/get.dart';
import 'package:coorent/bindings/app_bindings.dart';
import 'package:coorent/views/splash/splash_view.dart';
import 'package:coorent/views/login/login_view.dart';
import 'package:coorent/views/otp/otp_view.dart';
import 'package:coorent/views/register/register_view.dart';
import 'package:coorent/views/dashboard/dashboard_view.dart';
import 'package:coorent/views/services/services_view.dart';

class AppRoutes {
  static const initial = '/';

  static final routes = [
    GetPage(
      name: '/',
      page: () => const SplashView(),
      binding: AppBindings(),
    ),
    GetPage(
      name: '/login',
      page: () => const LoginView(),
    ),
    GetPage(
      name: '/otp',
      page: () => const OtpView(),
    ),
    GetPage(
      name: '/register',
      page: () => const RegisterView(),
    ),
    GetPage(
      name: '/dashboard',
      page: () => DashboardView(),
    ),
    GetPage(
      name: '/services',
      page: () => const ServicesView(),
    ),
  ];
}
