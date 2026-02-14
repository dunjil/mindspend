import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mindspend/features/profile/presentation/controllers/profile_controller.dart';
import '../../../../core/theme/app_colors.dart';

class SummaryCard extends StatelessWidget {
  final double income;
  final double expense;
  final double net;

  const SummaryCard({
    super.key,
    required this.income,
    required this.expense,
    required this.net,
  });

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    return Container(
      padding: EdgeInsets.all(24.w),
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
          Text(
            'This Month',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.h),
          Obx(
            () => _buildRow(
              'Income',
              income,
              AppColors.incomeGreen,
              profileController.currencySymbol,
            ),
          ),
          SizedBox(height: 12.h),
          Obx(
            () => _buildRow(
              'Expenses',
              -expense,
              AppColors.expenseGray,
              profileController.currencySymbol,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(color: AppColors.bgTertiary, thickness: 1),
          ),
          Obx(
            () => _buildRow(
              'Net',
              net,
              net >= 0 ? AppColors.netPositive : AppColors.netNegative,
              profileController.currencySymbol,
              isBold: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    double amount,
    Color color,
    String currencySymbol, {
    bool isBold = false,
  }) {
    final formattedAmount =
        '${amount < 0 ? '-' : ''}$currencySymbol${amount.abs().toStringAsFixed(2)}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
        ),
        Text(
          formattedAmount,
          style: TextStyle(
            fontSize: 18.sp,
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
