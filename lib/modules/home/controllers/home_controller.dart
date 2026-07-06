import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  AppUserModel? get user => _authService.user;
  RxBool get isLoading => _authService.isLoading;

  Future<void> logout() async {
    await _authService.signOut();
  }
}
