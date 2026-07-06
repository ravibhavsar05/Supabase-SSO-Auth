import 'package:get/get.dart';
import '../../data/services/auth_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Inject the authentication service globally and make it permanent
    Get.put<AuthService>(AuthService(), permanent: true);
  }
}
