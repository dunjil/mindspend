import 'package:get/get.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../../profile/presentation/pages/reminder_setup_page.dart';

enum SubscriptionPlan { weekly, monthly }

class SubscriptionController extends GetxController {
  final SubscriptionRepository _repository = SubscriptionRepository();
  final RxBool isLoading = false.obs;
  final Rx<SubscriptionPlan> selectedPlan = SubscriptionPlan.monthly.obs;

  bool get isPremium => _repository.isPremium;

  void selectPlan(SubscriptionPlan plan) {
    selectedPlan.value = plan;
  }

  Future<void> subscribe() async {
    try {
      isLoading.value = true;
      // In a real app, we would pass the selectedPlan to the repository
      await _repository.purchaseSubscription();

      // Navigate to ReminderSetupPage after success
      Get.offAll(() => ReminderSetupPage());

      // If we were on Profile and opened Paywall as a dialogue/page, go back
      if (Get.currentRoute.contains('PaywallPage') ||
          !Get.currentRoute.contains('MainNavigation')) {
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Purchase failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> restore() async {
    try {
      isLoading.value = true;
      await _repository.restorePurchases();
      Get.back(); // Close paywall
    } catch (e) {
      Get.snackbar('Error', 'Restore failed: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
