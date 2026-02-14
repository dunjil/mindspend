import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../../../gamification/presentation/controllers/gamification_controller.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_list_item.dart';
import '../../../transaction/presentation/widgets/transaction_edit_dialog.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Date Filter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  _buildDateRangeTile(context, controller),
                ],
              ),
              SizedBox(height: 20.h),
              // Gamification Card
              _EntranceAnimation(child: const _GamificationCard()),
              SizedBox(height: 20.h),

              // Mindfulness Calendar
              _EntranceAnimation(
                delay: const Duration(milliseconds: 50),
                child: const _MindfulnessCalendar(),
              ),
              SizedBox(height: 20.h),

              // Summary Card
              Obx(
                () => _EntranceAnimation(
                  delay: const Duration(milliseconds: 100),
                  child: SummaryCard(
                    income: controller.income.value,
                    expense: controller.expenses.value,
                    net: controller.net.value,
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              Text(
                'Recent Entries',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),

              // Transaction List
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.transactions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.h),
                      child: Text(
                        'No entries yet',
                        style: TextStyle(color: AppColors.textTertiary),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = controller.transactions[index];
                    return _EntranceAnimation(
                      delay: Duration(milliseconds: 200 + (index * 50)),
                      child: TransactionListItem(
                        transaction: transaction,
                        onTap: () {
                          Get.dialog(
                            TransactionEditDialog(transaction: transaction),
                          ).then((_) => controller.fetchTransactions());
                        },
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeTile(
    BuildContext context,
    DashboardController controller,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return GestureDetector(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange:
              controller.selectedDateRange.value ??
              DateTimeRange(
                start: DateTime.now().subtract(const Duration(days: 7)),
                end: DateTime.now(),
              ),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primaryBlue,
                  onPrimary: Colors.white,
                  onSurface: AppColors.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          controller.setDateRange(picked);
        }
      },
      child: Obx(() {
        final range = controller.selectedDateRange.value;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: range != null
                  ? AppColors.primaryOrange.withOpacity(0.5)
                  : AppColors.bgTertiary,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.date_range,
                size: 16.sp,
                color: range != null
                    ? AppColors.primaryOrange
                    : AppColors.textTertiary,
              ),
              SizedBox(width: 8.w),
              Text(
                range != null
                    ? '${dateFormat.format(range.start)} - ${dateFormat.format(range.end)}'
                    : 'All Time',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: range != null
                      ? AppColors.primaryOrange
                      : AppColors.textSecondary,
                  fontWeight: range != null
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              if (range != null) ...[
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => controller.setDateRange(null),
                  child: Icon(
                    Icons.close,
                    size: 14.sp,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _EntranceAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const _EntranceAnimation({required this.child, this.delay = Duration.zero});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        final bool show = snapshot.connectionState == ConnectionState.done;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: show ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 30.h * (1 - value)),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }
}

class _GamificationCard extends GetView<GamificationController> {
  const _GamificationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  'Level ${controller.currentLevel.value}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(Icons.emoji_events, color: Colors.amber, size: 24.sp),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final double progress = controller.progress;
            return ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 8.h,
              ),
            );
          }),
          SizedBox(height: 8.h),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.currentPoints.value} XP',
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                ),
                Text(
                  'Next Level: ${controller.nextLevelPoints} XP',
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MindfulnessCalendar extends GetView<DashboardController> {
  const _MindfulnessCalendar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mindfulness Streak',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Obx(() {
                final streakCount = controller.activeDays.length;
                return Text(
                  '$streakCount mindful days',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textTertiary,
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(() {
            final now = DateTime.now();
            final last30Days = List.generate(30, (index) {
              return DateTime(
                now.year,
                now.month,
                now.day,
              ).subtract(Duration(days: 29 - index));
            });

            return Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: last30Days.map((date) {
                final isActive = controller.activeDays.any(
                  (d) =>
                      d.year == date.year &&
                      d.month == date.month &&
                      d.day == date.day,
                );

                return Container(
                  width: (Get.width - 80.w - (7 * 8.w)) / 8.5,
                  height: (Get.width - 80.w - (7 * 8.w)) / 8.5,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryBlue
                        : AppColors.bgTertiary,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
