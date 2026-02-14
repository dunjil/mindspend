import 'package:get/get.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class SubscriptionRepository {
  final AuthController _authController = Get.find<AuthController>();

  // Use a reactive boolean for checking premium status efficiently
  bool get isPremium => _authController.currentUser.value?.isPremium ?? false;

  Future<void> purchaseSubscription() async {
    // Simulate API call / Store interaction
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, validation happens here.
    // For mock, we just tell AuthController to upgrade the user.
    await _authController.upgradeToPremium();
  }

  Future<void> restorePurchases() async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock restore logic
    if (true) {
      // Simulate success
      await _authController.upgradeToPremium();
    }
  }
}
