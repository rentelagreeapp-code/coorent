import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coorent/bindings/app_bindings.dart';
import 'package:coorent/core/routes/app_routes.dart';
import 'package:coorent/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CooRentApp());
}

class CooRentApp extends StatelessWidget {
  const CooRentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CooRent',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppRoutes.initial,
      initialBinding: AppBindings(),
      getPages: AppRoutes.routes,
      defaultTransition: Transition.cupertino,
    );
  }
}
