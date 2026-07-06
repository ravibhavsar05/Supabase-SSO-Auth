import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/bindings/initial_binding.dart';
import 'core/theme/app_theme.dart';
import 'core/values/constants.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");

    String initialRoute = AppRoutes.login;

    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        publishableKey: AppConstants.supabaseAnonKey,
      );

      // Check current session to redirect immediately
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        initialRoute = AppRoutes.home;
      }
    } catch (e) {
      debugPrint('Failed to initialize Supabase: $e');
    }

    runApp(MyApp(initialRoute: initialRoute));
  }, (error, stackTrace) {
    debugPrint('Uncaught async error: $error');
    if (error is AuthException) {
      Get.snackbar(
        'SSO Authentication Failed',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  });
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, this.initialRoute = AppRoutes.login});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SSO Login App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to a gorgeous dark mode experience
      initialBinding: InitialBinding(),
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
