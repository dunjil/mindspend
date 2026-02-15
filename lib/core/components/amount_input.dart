import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:mindspend/features/profile/presentation/controllers/profile_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class AmountInput extends StatefulWidget {
  final ValueChanged<double> onChanged;
  final VoidCallback? onSubmitted;
  final String? label;
  final TextEditingController? controller;

  const AmountInput({
    super.key,
    required this.onChanged,
    this.onSubmitted,
    this.label,
    this.controller,
  });

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_formatCurrency);

    // Listen to currency changes to refresh existing text
    ever(Get.find<ProfileController>().selectedCurrency, (_) {
      if (_controller.text.isNotEmpty) {
        final digits = _controller.text.replaceAll(RegExp(r'[^\d]'), '');
        if (digits.isNotEmpty) {
          final double value = double.parse(digits) / 100;
          final symbol = Get.find<ProfileController>().currencySymbol;
          _controller.text = '$symbol${value.toStringAsFixed(2)}';
        }
      }
    });
  }

  void _formatCurrency() {
    // This is a simplified formatter for the prototype
    // In a real app, use a dedicated package or more robust logic
    final text = _controller.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.isEmpty) {
      widget.onChanged(0.0);
      return;
    }

    final double value = double.parse(text) / 100;
    widget.onChanged(value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
        ],
        Obx(() {
          final profileController = Get.find<ProfileController>();
          final symbol = profileController.currencySymbol;

          return TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '${symbol}0.00',
              hintStyle: TextStyle(color: AppColors.textTertiary),
              border: InputBorder.none,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.bgTertiary, width: 2),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 8.h),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CurrencyInputFormatter(),
            ],
            onSubmitted: (_) => widget.onSubmitted?.call(),
            autofocus: true,
          );
        }),
      ],
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Strip everything except digits
    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      return oldValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    double value = double.parse(digits) / 100;
    final profileController = Get.find<ProfileController>();
    final symbol = profileController.currencySymbol;

    String newText = '$symbol${value.toStringAsFixed(2)}';

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
