
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/streak_controller.dart';

class StreakBadge extends GetView<StreakController> {
  const StreakBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox.shrink();
      }

      final currentStreak = controller.streak.value.currentStreak;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: currentStreak > 0 
              ? AppColors.streakActive 
              : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: currentStreak > 0 
                ? AppColors.streakBorder 
                : AppColors.bgTertiary,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🔥',
              style: TextStyle(fontSize: 18.sp),
            ),
            SizedBox(width: 6.w),
            Text(
              currentStreak > 0 
                  ? '$currentStreak day${currentStreak > 1 ? 's' : ''} streak'
                  : 'Start your streak!',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: currentStreak > 0 
                    ? AppColors.streakText 
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    });
  }
}
