import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/insights_controller.dart';
import '../widgets/category_pie_chart.dart';

class InsightsPage extends GetView<InsightsController> {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(InsightsController());
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar with Filter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Insights',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    _buildDateRangeTile(context, controller),
                  ],
                ),
                SizedBox(height: 16.h),
                SizedBox(height: 10.h),
                if (controller.transactions.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 100.h),
                        Icon(
                          Icons.query_stats,
                          size: 64.sp,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No data for this period',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Builder(
                    builder: (context) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Total Spending Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryBlue,
                                  AppColors.primaryOrange,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Spending',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Obx(
                                  () => Text(
                                    '${profileController.currencySymbol}${controller.totalSpending.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 32.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '${controller.transactionCount} transactions',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // Spending by Category
                          Text(
                            'Spending by Category',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: AppColors.bgSecondary,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: CategoryPieChart(
                              categoryTotals: controller.categoryTotals,
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Category List
                          ...controller.categoryTotals.entries.map((entry) {
                            final percentage =
                                (entry.value /
                                (controller.totalSpending == 0
                                    ? 1
                                    : controller.totalSpending) *
                                100);
                            return Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: AppColors.bgSecondary,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _getCategoryIcon(entry.key),
                                    style: TextStyle(fontSize: 20.sp),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getCategoryLabel(entry.key),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color:AppColors.textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          '${percentage.toStringAsFixed(1)}% of total',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Obx(
                                    () => Text(
                                      '${profileController.currencySymbol}${entry.value.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          SizedBox(height: 24.h),

                          // Emotion Breakdown
                          Text(
                            'How You Feel About Spending',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          ...controller.emotionCounts.entries.map((entry) {
                            final total = controller.emotionCounts.values.fold(
                              0,
                              (sum, count) => sum + count,
                            );
                            final percentage = total > 0
                                ? (entry.value / total * 100)
                                : 0.0;

                            return Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: AppColors.bgSecondary,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _getEmotionEmoji(entry.key),
                                    style: TextStyle(fontSize: 24.sp),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      _getEmotionLabel(entry.key),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color:  AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    '(${entry.value})',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDateRangeTile(
    BuildContext context,
    InsightsController controller,
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

  String _getCategoryIcon(String id) {
    switch (id.toLowerCase()) {
      case 'food':
        return '☕';
      case 'transport':
        return '🚗';
      case 'shopping':
        return '🛍️';
      case 'bills':
        return '💡';
      case 'fun':
        return '🎭';
      case 'home':
        return '🏠';
      case 'salary':
        return '💰';
      case 'freelance':
        return '💻';
      case 'gift':
        return '🎁';
      default:
        return '💸';
    }
  }

  String _getCategoryLabel(String id) {
    switch (id.toLowerCase()) {
      case 'food':
        return 'Food';
      case 'transport':
        return 'Transport';
      case 'shopping':
        return 'Shopping';
      case 'bills':
        return 'Bills';
      case 'fun':
        return 'Fun';
      case 'home':
        return 'Home';
      case 'salary':
        return 'Salary';
      case 'freelance':
        return 'Project';
      case 'gift':
        return 'Gift';
      default:
        return 'Other';
    }
  }

  String _getEmotionEmoji(String id) {
    switch (id.toLowerCase()) {
      case 'good':
        return '😊';
      case 'neutral':
        return '😐';
      case 'bad':
        return '😞';
      default:
        return '❓';
    }
  }

  String _getEmotionLabel(String id) {
    switch (id.toLowerCase()) {
      case 'good':
        return 'Worth it';
      case 'neutral':
        return 'Meh';
      case 'bad':
        return 'Regret';
      default:
        return 'Unknown';
    }
  }
}
