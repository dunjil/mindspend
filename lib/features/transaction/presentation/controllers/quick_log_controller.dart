import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mindspend/core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:mindspend/features/transaction/domain/models/transaction_model.dart';
import 'package:mindspend/features/transaction/data/repositories/local_transaction_repository.dart';
// import '../../data/repositories/mock_transaction_repository.dart';
import '../widgets/emotion_selection_sheet.dart';
import 'package:mindspend/features/streak/presentation/controllers/streak_controller.dart';
import 'package:mindspend/core/navigation/navigation_controller.dart';
import '../../../gamification/presentation/controllers/gamification_controller.dart';
import 'package:mindspend/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:mindspend/features/insights/presentation/controllers/insights_controller.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class QuickLogController extends GetxController {
  final LocalTransactionRepository _repository = LocalTransactionRepository();
  final StreakController streakController = Get.find<StreakController>();
  late final ConfettiController confettiController;

  final RxDouble amount = 0.0.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedEmotion = ''.obs;
  final RxString note = ''.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isLoading = false.obs;
  final RxBool showEmotionPicker = false.obs;

  final RxBool isIncome = false.obs;
  final RxString timeOfDay = ''.obs;

  late final TextEditingController amountController;
  late final TextEditingController noteController;

  @override
  void onInit() {
    super.onInit();
    amountController = TextEditingController();
    noteController = TextEditingController();
    confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    confettiController.dispose();
    super.onClose();
  }

  // Categories based on design spec
  final List<CategoryItem> categories = [
    CategoryItem(id: 'food', label: 'Food', icon: '☕'),
    CategoryItem(id: 'transport', label: 'Transport', icon: '🚗'),
    CategoryItem(id: 'shopping', label: 'Shopping', icon: '🛍️'),
    CategoryItem(id: 'bills', label: 'Bills', icon: '💡'),
    CategoryItem(id: 'fun', label: 'Fun', icon: '🎭'),
    CategoryItem(id: 'home', label: 'Home', icon: '🏠'),
    CategoryItem(id: 'other', label: 'Other', icon: '💸'),
  ];

  final List<CategoryItem> incomeCategories = [
    CategoryItem(id: 'salary', label: 'Salary', icon: '💰'),
    CategoryItem(id: 'freelance', label: 'Project', icon: '💻'),
    CategoryItem(id: 'gift', label: 'Gift', icon: '🎁'),
    CategoryItem(id: 'other_income', label: 'Other', icon: '💵'),
  ];

  final List<String> mindfulQuotes = [
    "One step closer to your financial peace. ✨",
    "Your future self is thanking you for this mindfulness. 🧘‍♂️",
    "Great job being aware of your spendings! 🚀",
    "Small logs lead to big habits. Proud of you! 💎",
    "Awareness is the first step to financial freedom. 🦁",
    "You're mastering your money, one log at a time. 🎯",
    "Money flows to where it is respected. Great work! 🌈",
  ];

  String getRandomQuote() {
    return mindfulQuotes[Random().nextInt(mindfulQuotes.length)];
  }

  final RxnString lastTransactionId = RxnString();

  void setAmount(double value) {
    amount.value = value;
  }

  void toggleIncome(bool value) {
    isIncome.value = value;
    selectedCategory.value = ''; // Reset category when switching type
  }

  void setNote(String value) {
    note.value = value;
  }

  void setEmotion(String emotion) {
    selectedEmotion.value = emotion;
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  void resetForm() {
    amount.value = 0.0;
    selectedCategory.value = '';
    selectedEmotion.value = '';
    note.value = '';
    selectedDate.value = DateTime.now();
    showEmotionPicker.value = false;
    isIncome.value = false;
    amountController.clear();
    noteController.clear();
  }

  void selectCategory(String categoryId) {
    selectedCategory.value = categoryId;
  }

  String _calculateTimeOfDay(DateTime date) {
    final hour = date.hour;
    if (hour >= 5 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 17) return 'Afternoon';
    if (hour >= 17 && hour < 21) return 'Evening';
    return 'Night';
  }

  Future<void> submitTransaction() async {
    if (amount.value <= 0 || selectedCategory.value.isEmpty) return;

    isLoading.value = true;
    try {
      final newId = const Uuid().v4();
      final calculatedTimeOfDay = _calculateTimeOfDay(selectedDate.value);

      final transaction = TransactionModel(
        id: newId,
        amount: amount.value,
        category: selectedCategory.value,
        date: selectedDate.value,
        emotion: selectedEmotion.value.isNotEmpty
            ? selectedEmotion.value
            : null,
        note: note.value.isNotEmpty ? note.value : null,
        isIncome: isIncome.value,
        timeOfDay: calculatedTimeOfDay,
      );

      await _repository.addTransaction(transaction);
      lastTransactionId.value = newId;

      // Celebrate!
      confettiController.play();

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 48.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  isIncome.value ? 'Income Recorded!' : 'Expense Logged!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  getRandomQuote(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Keep Going',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Reset form
      resetForm();

      // Update streak
      await streakController.updateStreakOnLog();

      // Award Points
      final gamificationController = Get.find<GamificationController>();
      await gamificationController.addPoints(10);
      // Refresh other controllers
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().fetchTransactions();
      }
      if (Get.isRegistered<InsightsController>()) {
        Get.find<InsightsController>().loadInsights();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save transaction: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onDoneForToday() {
    // If we just logged something and it doesn't have an emotion yet, ask for it
    if (lastTransactionId.value != null && selectedEmotion.value.isEmpty) {
      // Trigger Emotion Sheet via the View (passed as callback or using Get.bottomSheet here)
      // ideally, the View calls this, and we handle logic.
      // Let's open the sheet from here for simplicity in GetX
      Get.bottomSheet(
        EmotionSelectionSheet(
          onEmotionSelected: (emotion) {
            submitEmotion(emotion);
            Get.back(); // Close sheet
            // Navigate to Dashboard tab
            final navController = Get.find<NavigationController>();
            navController.changePage(1);
          },
          onSkip: () {
            Get.back();
            // Navigate to Dashboard tab
            final navController = Get.find<NavigationController>();
            navController.changePage(1);
          },
        ),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
      );
    } else {
      // Navigate to Dashboard tab
      final navController = Get.find<NavigationController>();
      navController.changePage(1);
    }
  }

  Future<void> submitEmotion(String emotion) async {
    if (lastTransactionId.value == null) return;

    // In a real app, we'd fetch the transaction first or update fields directly
    // For mock, we create a dummy update
    // limitation: we don't have the full previous transaction object here easily without fetching
    // ensuring we are just updating the emotion of the last added transaction
    // For this prototype, let's assume we can fetch it or just simulate the update

    // To do it right:
    // final transaction = await _repository.getTransaction(lastTransactionId.value!);
    // final updated = transaction.copyWith(emotion: emotion);
    // await _repository.updateTransaction(updated);

    selectedEmotion.value = emotion; // Update local state
    // We will implement full update logic when we have the real repository
  }
}

class CategoryItem {
  final String id;
  final String label;
  final String icon;

  CategoryItem({required this.id, required this.label, required this.icon});
}
