
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/emotion_button.dart';

class EmotionSelectionSheet extends StatelessWidget {
  final Function(String) onEmotionSelected;
  final VoidCallback onSkip;

  const EmotionSelectionSheet({
    super.key,
    required this.onEmotionSelected,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Quick reflection:',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Was this spending worth it?',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 32.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              EmotionButton(
                emoji: '😊',
                label: 'Good',
                isSelected: false,
                onTap: () => onEmotionSelected('good'),
                selectedColor: AppColors.emotionGood,
                selectedBgColor: AppColors.emotionGoodBg,
              ),
              EmotionButton(
                emoji: '😐',
                label: 'Meh',
                isSelected: false,
                onTap: () => onEmotionSelected('neutral'),
                selectedColor: AppColors.emotionNeutral,
                selectedBgColor: AppColors.bgTertiary,
              ),
              EmotionButton(
                emoji: '😞',
                label: 'Bad',
                isSelected: false,
                onTap: () => onEmotionSelected('bad'),
                selectedColor: AppColors.emotionBad,
                selectedBgColor: AppColors.emotionBadBg,
              ),
            ],
          ),
          SizedBox(height: 32.h),
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Skip',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 14.sp,
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
