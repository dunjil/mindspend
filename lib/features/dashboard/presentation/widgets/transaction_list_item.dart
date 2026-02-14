
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:mindspend/features/transaction/domain/models/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2);
    final dateFormat = DateFormat('MMM d');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.bgTertiary),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.bgTertiary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  _getCategoryIcon(transaction.category),
                  style: TextStyle(fontSize: 20.sp),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getCategoryLabel(transaction.category),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    dateFormat.format(transaction.date),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-${currencyFormat.format(transaction.amount)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.expenseGray,
                  ),
                ),
                if (transaction.emotion != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      _getEmotionEmoji(transaction.emotion!),
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryIcon(String id) {
    // Should reuse the list from controller, but simple switch here for now
    switch (id) {
      case 'food': return '☕';
      case 'transport': return '🚗';
      case 'shopping': return '🛍️';
      case 'bills': return '💡';
      case 'fun': return '🎭';
      case 'home': return '🏠';
      default: return '💸';
    }
  }

  String _getCategoryLabel(String id) {
    switch (id) {
      case 'food': return 'Food';
      case 'transport': return 'Transport';
      case 'shopping': return 'Shopping';
      case 'bills': return 'Bills';
      case 'fun': return 'Fun';
      case 'home': return 'Home';
      default: return 'Other';
    }
  }

  String _getEmotionEmoji(String id) {
    switch (id) {
      case 'good': return '😊';
      case 'neutral': return '😐';
      case 'bad': return '😞';
      default: return '';
    }
  }
}
