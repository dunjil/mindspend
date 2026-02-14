import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/main_navigation.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindspend/core/theme/app_colors.dart';
import 'package:in_app_review/in_app_review.dart';
import 'core/bindings/initial_binding.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set initial System UI Overlay Style (will be updated by MainNavigation)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.init();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Simulate checking for updates and requesting review after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
      _requestReview();
    });
  }

  Future<bool> _isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }

  void _checkForUpdates() async {
    // Mock Update Check
    await Future.delayed(const Duration(seconds: 3)); // Wait a bit
    if (Get.context != null) {
      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.rocket_launch, color: AppColors.primaryOrange),
              SizedBox(width: 8.w),
              Text('Update Available!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version 2.0 is here with amazing new features!'),
              SizedBox(height: 8.h),
              Text('• Dark Mode Support'),
              Text('• Cloud Sync'),
              Text('• Enhanced Insights'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('Later')),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar('Updating', 'Redirecting to store...');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
              ),
              child: Text('Update Now', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  void _requestReview() async {
    // Request review after a short delay
    await Future.delayed(const Duration(seconds: 5));
    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil for responsive design based on iPhone 12/13/14 (390x844) as per spec
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MindSpend',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialBinding: InitialBinding(),
          home: FutureBuilder<bool>(
            future: _isOnboardingComplete(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return snapshot.data == true
                  ? const MainNavigation()
                  : const OnboardingPage();
            },
          ),
        );
      },
    );
  }
}
