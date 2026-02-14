import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/subscription_controller.dart';

class PaywallPage extends GetView<SubscriptionController> {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SubscriptionController>()) {
      Get.put(SubscriptionController());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light, // iOS dark icons
        systemNavigationBarColor: AppColors.bgSecondary,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Stack(
          children: [
            // Background Image or Gradient could go here
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.bgPrimary, AppColors.bgSecondary],
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  if (controller.isPremium)
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close, color: AppColors.textPrimary),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 20.h),
                          Icon(
                            Icons.workspace_premium, // Or a custom premium icon
                            size: 80.sp,
                            color: AppColors.primaryBlue,
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'Unlock MindSpend Premium',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Supercharge your financial mindfulness with these exclusive features.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 40.h),

                          _buildFeatureRow(
                            Icons.file_download,
                            'Export Data (CSV & PDF)',
                          ),
                          _buildFeatureRow(
                            Icons.cloud_sync,
                            'Cloud Sync across devices',
                          ),
                          _buildFeatureRow(
                            Icons.insights,
                            'Advanced Insights & Analytics',
                          ),
                          _buildFeatureRow(
                            Icons.color_lens,
                            'Custom Themes & Icons',
                          ),
                          _buildFeatureRow(
                            Icons.calendar_month,
                            'Unlimited History',
                          ),

                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Section
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildPlanOption(
                                title: 'Weekly',
                                price: '\$1.99',
                                plan: SubscriptionPlan.weekly,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: _buildPlanOption(
                                title: 'Monthly',
                                price: '\$4.99',
                                plan: SubscriptionPlan.monthly,
                                isBestValue: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () => controller.subscribe(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 0,
                              ),
                              child: controller.isLoading.value
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        TextButton(
                          onPressed: () => controller.restore(),
                          child: Text(
                            'Restore Purchases',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOption({
    required String title,
    required String price,
    required SubscriptionPlan plan,
    bool isBestValue = false,
  }) {
    return Obx(() {
      final isSelected = controller.selectedPlan.value == plan;
      return GestureDetector(
        onTap: () => controller.selectPlan(plan),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBlue.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : AppColors.bgTertiary,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              if (isBestValue)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'BEST VALUE',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (isBestValue) SizedBox(height: 8.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                price,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
