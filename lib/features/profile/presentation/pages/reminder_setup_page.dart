import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/profile_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';

class ReminderSetupPage extends StatelessWidget {
  ReminderSetupPage({super.key});

  final _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.bgPrimary,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                Text(
                  'Stay Consistent',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Set up daily reminders to help you build a mindful spending habit.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 48.h),

                _buildReminderTile(
                  context,
                  title: 'Morning Reminder',
                  subtitle: 'Log your morning mood and any early expenses.',
                  icon: Icons.wb_sunny_outlined,
                  isEnabled: controller.morningReminderEnabled,
                  time: controller.morningHour,
                  minute: controller.morningMinute,
                  onToggle: controller.toggleMorningReminder,
                  onTimeTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: controller.morningTime,
                    );
                    if (picked != null) {
                      controller.updateMorningTime(picked);
                    }
                  },
                ),

                SizedBox(height: 24.h),

                _buildReminderTile(
                  context,
                  title: 'Evening Reflection',
                  subtitle: 'A quick wrap-up of your day\'s spending.',
                  icon: Icons.nightlight_round_outlined,
                  isEnabled: controller.eveningReminderEnabled,
                  time: controller.eveningHour,
                  minute: controller.eveningMinute,
                  onToggle: controller.toggleEveningReminder,
                  onTimeTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: controller.eveningTime,
                    );
                    if (picked != null) {
                      controller.updateEveningTime(picked);
                    }
                  },
                ),

                SizedBox(height: 16.h),

                Center(
                  child: TextButton.icon(
                    onPressed: () =>
                        _notificationService.showTestNotification(),
                    icon: const Icon(
                      Icons.notification_important,
                      color: AppColors.primaryOrange,
                    ),
                    label: Text(
                      'Try Test Notification',
                      style: TextStyle(color: AppColors.primaryOrange),
                    ),
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () => controller.completeReminderSetup(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Continue to Dashboard',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Center(
                  child: TextButton(
                    onPressed: () => controller.completeReminderSetup(),
                    child: Text(
                      'Skip for now',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required RxBool isEnabled,
    required RxInt time,
    required RxInt minute,
    required Function(bool) onToggle,
    required VoidCallback onTimeTap,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.bgTertiary),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryOrange, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => Switch.adaptive(
                  value: isEnabled.value,
                  onChanged: onToggle,
                  activeColor: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
          Obx(
            () => isEnabled.value
                ? Column(
                    children: [
                      const Divider(height: 24),
                      GestureDetector(
                        onTap: onTimeTap,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reminder Time',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bgTertiary,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '${time.value.toString().padLeft(2, '0')}:${minute.value.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
