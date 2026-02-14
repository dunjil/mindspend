import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'navigation_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../../features/transaction/presentation/pages/quick_log_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/insights/presentation/pages/insights_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/reminder_setup_page.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../../features/subscription/presentation/pages/paywall_page.dart';
import '../../features/subscription/presentation/controllers/subscription_controller.dart';
// NavigationController is defined in this file

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<NavigationController>();
    final sub = Get.find<SubscriptionController>();
    final profile = Get.find<ProfileController>();

    return Obx(() {
      // If not subscribed, show Paywall as the primary screen
      if (!sub.isPremium) {
        return const PaywallPage();
      }

      // If premium but haven't configured reminders, force setup
      if (!profile.remindersConfigured.value) {
        return ReminderSetupPage();
      }

      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.dark : Brightness.light,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemStatusBarContrastEnforced: false,
          systemNavigationBarColor: theme.scaffoldBackgroundColor,
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: Scaffold(
          body: IndexedStack(
            index: nav.currentIndex.value,
            children: const [
              QuickLogPage(),
              DashboardPage(),
              InsightsPage(),
              ProfilePage(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(
                    0.05,
                  ),
                  width: 1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: nav.currentIndex.value,
              onTap: nav.changePage,
              type: BottomNavigationBarType.fixed,
              backgroundColor: theme.scaffoldBackgroundColor,
              selectedItemColor: AppColors.primaryOrange,
              unselectedItemColor: isDark
                  ? Colors.white54
                  : AppColors.textTertiary,
              selectedFontSize: 12.sp,
              unselectedFontSize: 12.sp,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline),
                  activeIcon: Icon(Icons.add_circle),
                  label: 'Log',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.insights_outlined),
                  activeIcon: Icon(Icons.insights),
                  label: 'Insights',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
