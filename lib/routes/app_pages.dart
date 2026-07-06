import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import 'app_routes.dart';

class AppPages {
  static const String initial = AppRoutes.login;
  static final List<GetPage> pages = [
    // Default root path
    GetPage(
      name: '/',
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    // Standard deep link route
    GetPage(
      name: AppRoutes.loginCallback,
      page: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    ),

    GetPage(
      name: '/login-callback/',
      page: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    ),
  ];}
