import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/components/amount_input.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/quick_log_controller.dart';
import 'package:mindspend/features/streak/presentation/controllers/streak_controller.dart';
import 'package:confetti/confetti.dart';

class QuickLogPage extends GetView<QuickLogController> {
  const QuickLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are registered
    final controller = Get.find<QuickLogController>();
    Get.put(StreakController());

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Motivational Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Let\'s log your spending or income today',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GetBuilder<StreakController>(
                          init: Get.find<StreakController>(),
                          builder: (streakCtrl) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  color: AppColors.primaryOrange,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${streakCtrl.streak.value.currentStreak} Day Streak',
                                  style: TextStyle(
                                    color: AppColors.primaryOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Top Bar: Toggle
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    child: Obx(
                      () => Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.toggleIncome(false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: !controller.isIncome.value
                                        ? AppColors.primaryOrange
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Expense',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: !controller.isIncome.value
                                            ? Colors.white
                                            : AppColors.textTertiary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.toggleIncome(true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: controller.isIncome.value
                                        ? Colors.green
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Income',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: controller.isIncome.value
                                            ? Colors.white
                                            : AppColors.textTertiary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Main Content Area (Scrollable if needed, but designed to fit)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date & Time (Interactive)
                            // Amount Input (No Label, Compact)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: AmountInput(
                                controller: controller.amountController,
                                onChanged: controller.setAmount,
                                onSubmitted: () {},
                                label: null, // Hide label
                              ),
                            ),

                            SizedBox(height: 8.h),
                            Text(
                              'Date & Time',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            GestureDetector(
                              onTap: () => controller.pickDate(context),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 15.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.bgSecondary,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: AppColors.textTertiary.withOpacity(
                                      0.3,
                                    ),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16.sp,
                                      color: AppColors.textPrimary,
                                    ),
                                    SizedBox(width: 8.w),
                                    Obx(
                                      () => Text(
                                        '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    Obx(
                                      () => Text(
                                        controller.timeOfDay.value.isNotEmpty
                                            ? controller.timeOfDay.value
                                            : 'Now',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Icon(
                                      Icons.edit_calendar_outlined,
                                      size: 16.sp,
                                      color: AppColors.primaryOrange,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),

                            // Category Grid
                            Text(
                              'Select Category',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              height: 75.h,
                              child: Obx(() {
                                final categories = controller.isIncome.value
                                    ? controller.incomeCategories
                                    : controller.categories;
                                final activeColor = controller.isIncome.value
                                    ? Colors.green
                                    : AppColors.primaryOrange;

                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: categories.length,
                                  itemBuilder: (context, index) {
                                    final cat = categories[index];

                                    return Padding(
                                      padding: EdgeInsets.only(right: 12.w),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () =>
                                              controller.selectCategory(cat.id),
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          child: Obx(() {
                                            final isSelected =
                                                controller
                                                    .selectedCategory
                                                    .value ==
                                                cat.id;
                                            return Container(
                                              width: 64.w,
                                              margin: EdgeInsets.only(
                                                right: 12.w,
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: 48.w,
                                                    height: 48.w,
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? activeColor
                                                          : AppColors
                                                                .bgSecondary,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: isSelected
                                                            ? activeColor
                                                            : Colors
                                                                  .transparent,
                                                        width: 2,
                                                      ),
                                                      boxShadow: isSelected
                                                          ? [
                                                              BoxShadow(
                                                                color: activeColor
                                                                    .withOpacity(
                                                                      0.3,
                                                                    ),
                                                                blurRadius: 8,
                                                                offset: Offset(
                                                                  0,
                                                                  2,
                                                                ),
                                                              ),
                                                            ]
                                                          : null,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        cat.icon,
                                                        style: TextStyle(
                                                          fontSize: 20.sp,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 6.h),
                                                  Text(
                                                    cat.label,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 11.sp,
                                                      fontWeight: isSelected
                                                          ? FontWeight.w600
                                                          : FontWeight.w500,
                                                      color: isSelected
                                                          ? activeColor
                                                          : AppColors
                                                                .textPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),

                            SizedBox(height: 16.h),

                            // Feelings Section (Visible)
                            Text(
                              'How do you feel?',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _emotionButton('😊', 'good', 'Worth it'),
                                _emotionButton('😐', 'neutral', 'Neutral'),
                                _emotionButton('😞', 'bad', 'Regret'),
                              ],
                            ),
                            SizedBox(height: 16.h),

                            // Notes Section (Visible with Border)
                            Text(
                              'Notes',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextField(
                              controller: controller.noteController,
                              onChanged: controller.setNote,
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Add a note about this transaction...',
                                hintStyle: TextStyle(
                                  color: AppColors.textTertiary,
                                ),
                                filled: true,
                                fillColor: AppColors.bgSecondary,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: AppColors.textTertiary.withOpacity(
                                      0.3,
                                    ),
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryOrange,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(16.w),
                              ),
                            ),

                            SizedBox(height: 24.h), // Space for bottom button
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom Action Bar
                  Container(
                    padding: EdgeInsets.all(24.w),
                    color: Colors.white,
                    child: Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.submitTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.isIncome.value
                                ? Colors.green
                                : AppColors.primaryOrange,
                            disabledBackgroundColor: AppColors.textTertiary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            elevation: 2,
                          ),
                          child: controller.isLoading.value
                              ? SizedBox(
                                  width: 24.w,
                                  height: 24.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  controller.isIncome.value
                                      ? 'Log Income'
                                      : 'Log Expense',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Confetti!
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: controller.confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  AppColors.primaryBlue,
                  AppColors.primaryOrange,
                  Colors.green,
                  Colors.yellow,
                  Colors.pink,
                ],
                minimumSize: const Size(10, 10),
                maximumSize: const Size(30, 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emotionButton(String emoji, String value, String label) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: Obx(
          () => InkWell(
            onTap: () => controller.setEmotion(
              controller.selectedEmotion.value == value ? '' : value,
            ),
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: controller.selectedEmotion.value == value
                    ? (controller.isIncome.value
                          ? Colors.green
                          : AppColors.primaryOrange)
                    : AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: controller.selectedEmotion.value == value
                      ? (controller.isIncome.value
                            ? Colors.green
                            : AppColors.primaryOrange)
                      : AppColors.textTertiary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: TextStyle(fontSize: 24.sp)),
                  SizedBox(height: 4.h),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: controller.selectedEmotion.value == value
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }
}
