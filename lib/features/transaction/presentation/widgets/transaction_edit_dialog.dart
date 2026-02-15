import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mindspend/features/transaction/domain/models/transaction_model.dart';
import 'package:mindspend/features/transaction/data/repositories/local_transaction_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/quick_log_controller.dart';
import 'package:mindspend/features/dashboard/presentation/controllers/dashboard_controller.dart';

class TransactionEditDialog extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionEditDialog({super.key, required this.transaction});

  @override
  State<TransactionEditDialog> createState() => _TransactionEditDialogState();
}

class _TransactionEditDialogState extends State<TransactionEditDialog> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late String _selectedCategory;
  late String? _selectedEmotion;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    _noteController = TextEditingController(
      text: widget.transaction.note ?? '',
    );
    _selectedCategory = widget.transaction.category;
    _selectedEmotion = widget.transaction.emotion;
    _selectedDate = widget.transaction.date;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuickLogController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Transaction',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),

              // Amount
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Category
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                items: controller.categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Row(
                      children: [
                        Text(cat.icon, style: TextStyle(fontSize: 20.sp)),
                        SizedBox(width: 8.w),
                        Text(cat.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              SizedBox(height: 16.h),

              // Emotion
              Text('Emotion (Optional)', style: TextStyle(fontSize: 14.sp)),
              SizedBox(height: 8.h),
              Row(
                children: [
                  _emotionChip('😊', 'good'),
                  SizedBox(width: 8.w),
                  _emotionChip('😐', 'neutral'),
                  SizedBox(width: 8.w),
                  _emotionChip('😞', 'bad'),
                  SizedBox(width: 8.w),
                  _emotionChip('Clear', null),
                ],
              ),
              SizedBox(height: 16.h),

              // Date
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                      Icon(Icons.calendar_today, size: 20.sp),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Note
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Note (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showDeleteConfirmation(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorRed,
                      ),
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final updated = TransactionModel(
                          id: widget.transaction.id,
                          amount: double.parse(_amountController.text),
                          category: _selectedCategory,
                          date: _selectedDate,
                          emotion: _selectedEmotion,
                          note: _noteController.text.isEmpty
                              ? null
                              : _noteController.text,
                        );

                        final repo = LocalTransactionRepository();
                        await repo.updateTransaction(updated);

                        if (Get.isRegistered<DashboardController>()) {
                          Get.find<DashboardController>().fetchTransactions();
                        }

                        Get.back();
                        Get.snackbar('Success', 'Transaction updated');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Transaction'),
        content: Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              final dashboardController = Get.find<DashboardController>();
              await dashboardController.deleteTransaction(
                widget.transaction.id,
              );
              Get.back(); // Close confirmation
              Get.back(); // Close edit dialog
              Get.snackbar('Success', 'Transaction deleted');
            },
            child: Text('Delete', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }

  Widget _emotionChip(String label, String? value) {
    final isSelected = _selectedEmotion == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedEmotion = selected ? value : null;
        });
      },
      selectedColor: AppColors.primaryOrange.withValues(alpha: 0.3),
    );
  }
}
