import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindspend/features/transaction/domain/models/transaction_model.dart';
import 'package:mindspend/features/transaction/data/repositories/local_transaction_repository.dart';

class InsightsController extends GetxController {
  final LocalTransactionRepository _repository = LocalTransactionRepository();

  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, double> categoryTotals = <String, double>{}.obs;
  final RxMap<String, int> emotionCounts = <String, int>{}.obs;
  final Rx<DateTimeRange?> selectedDateRange = Rx<DateTimeRange?>(null);

  @override
  void onInit() {
    super.onInit();
    loadInsights();
  }

  Future<void> loadInsights() async {
    isLoading.value = true;
    try {
      var data = await _repository.getTransactions();

      // Filter by date range if selected
      if (selectedDateRange.value != null) {
        data = data.where((t) {
          return t.date.isAfter(
                selectedDateRange.value!.start.subtract(
                  const Duration(seconds: 1),
                ),
              ) &&
              t.date.isBefore(
                selectedDateRange.value!.end.add(const Duration(days: 1)),
              );
        }).toList();
      }

      transactions.assignAll(data);
      calculateCategoryTotals();
      calculateEmotionBreakdown();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load insights: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setDateRange(DateTimeRange? range) {
    selectedDateRange.value = range;
    loadInsights();
  }

  void calculateCategoryTotals() {
    final Map<String, double> totals = {};
    for (var transaction in transactions) {
      // Only include expenses in category breakdown
      if (!transaction.isIncome) {
        totals[transaction.category] =
            (totals[transaction.category] ?? 0) + transaction.amount;
      }
    }
    categoryTotals.assignAll(totals);
  }

  void calculateEmotionBreakdown() {
    final Map<String, int> counts = {};
    for (var transaction in transactions) {
      if (transaction.emotion != null && transaction.emotion!.isNotEmpty) {
        counts[transaction.emotion!] = (counts[transaction.emotion!] ?? 0) + 1;
      }
    }
    emotionCounts.assignAll(counts);
  }

  double get totalSpending => transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalIncome => transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  int get transactionCount => transactions.length;
}
