import 'package:get/get.dart';
import 'package:mindspend/features/transaction/domain/models/transaction_model.dart';
import 'package:mindspend/features/transaction/data/repositories/local_transaction_repository.dart';

class InsightsController extends GetxController {
  final LocalTransactionRepository _repository = LocalTransactionRepository();

  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, double> categoryTotals = <String, double>{}.obs;
  final RxMap<String, int> emotionCounts = <String, int>{}.obs;
  final Rx<DateTime> startDate = DateTime.now()
      .subtract(const Duration(days: 7))
      .obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    ever(startDate, (_) => loadInsights());
    ever(endDate, (_) => loadInsights());
    loadInsights();
  }

  Future<void> loadInsights() async {
    isLoading.value = true;
    try {
      var data = await _repository.getTransactions();

      // Filter by date range
      data = data.where((t) {
        return t.date.isAfter(
              startDate.value.subtract(const Duration(seconds: 1)),
            ) &&
            t.date.isBefore(endDate.value.add(const Duration(days: 1)));
      }).toList();

      transactions.assignAll(data);
      calculateCategoryTotals();
      calculateEmotionBreakdown();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load insights: $e');
    } finally {
      isLoading.value = false;
    }
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
