import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  RxBool get isLoading => _authService.isLoading;
  RxBool get isGoogleLoading => _authService.isGoogleLoading;
  RxBool get isAppleLoading => _authService.isAppleLoading;

  Future<void> loginWithGoogle() async {
    await _authService.signInWithOAuth(OAuthProvider.google);
  }

  Future<void> loginWithApple() async {
    await _authService.signInWithOAuth(OAuthProvider.apple);
  }
}
