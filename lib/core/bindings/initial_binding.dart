import 'package:get/get.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/subscription/presentation/controllers/subscription_controller.dart';
import '../../features/streak/presentation/controllers/streak_controller.dart';
import '../../features/gamification/presentation/controllers/gamification_controller.dart';
import '../../core/navigation/navigation_controller.dart';
import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../features/transaction/presentation/controllers/quick_log_controller.dart';
import '../../features/insights/presentation/controllers/insights_controller.dart';
import '../../features/profile/presentation/controllers/export_controller.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Global Controllers
    Get.put(AuthController());
    Get.put(SubscriptionController());
    Get.put(StreakController());
    Get.put(GamificationController());
    Get.put(NavigationController());

    // Lazy Loaded Controllers
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => QuickLogController());
    Get.lazyPut(() => InsightsController());
    Get.lazyPut(() => ExportController());
    Get.put(ProfileController());
  }
}
