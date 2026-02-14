import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const CategoryPieChart({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return Center(
        child: Text(
          'No spending data',
          style: TextStyle(color: AppColors.textTertiary),
        ),
      );
    }

    final total = categoryTotals.values.fold(0.0, (sum, val) => sum + val);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: PieChartPainter(
                categoryTotals: categoryTotals,
                total: total,
              ),
              child: Center(
                child: Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categoryTotals.entries.map((entry) {
              final percentage = (entry.value / total * 100).toStringAsFixed(0);
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: PieChartPainter.getCategoryColorStatic(
                          entry.key,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        entry.key[0].toUpperCase() + entry.key.substring(1),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, double> categoryTotals;
  final double total;

  PieChartPainter({required this.categoryTotals, required this.total});

  static Color getCategoryColorStatic(String category) {
    switch (category) {
      case 'food':
        return const Color(0xFFEF4444);
      case 'transport':
        return const Color(0xFF3B82F6);
      case 'shopping':
        return const Color(0xFFF59E0B);
      case 'bills':
        return const Color(0xFF10B981);
      case 'fun':
        return const Color(0xFF8B5CF6);
      case 'home':
        return const Color(0xFF06B6D4);
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // ... rest of paint logic ...
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -pi / 2;

    for (var entry in categoryTotals.entries) {
      final sweepAngle = (entry.value / total) * 2 * pi;
      if (sweepAngle == 0) continue;

      final paint = Paint()
        ..color = getCategoryColorStatic(entry.key)
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);

      final borderPaint = Paint()
        ..color = AppColors.bgSecondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(rect, startAngle, sweepAngle, true, borderPaint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
