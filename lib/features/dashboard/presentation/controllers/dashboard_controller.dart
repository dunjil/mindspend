import 'package:get/get.dart';
import 'package:mindspend/features/transaction/domain/models/transaction_model.dart';
import 'package:mindspend/features/transaction/data/repositories/local_transaction_repository.dart';
import 'package:intl/intl.dart';

class DashboardController extends GetxController {
  final LocalTransactionRepository _repository = LocalTransactionRepository();

  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxDouble income = 0.0.obs;
  final RxDouble expenses = 0.0.obs;
  final RxDouble net = 0.0.obs;
  final RxBool isLoading = false.obs;
  final Rx<DateTime> startDate = DateTime.now()
      .subtract(const Duration(days: 7))
      .obs;
  final Rx<DateTime> endDate = DateTime.now().obs;
  final RxList<DateTime> activeDays = <DateTime>[].obs;

  @override
  void onInit() {
    super.onInit();
    ever(startDate, (_) => fetchTransactions());
    ever(endDate, (_) => fetchTransactions());
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    isLoading.value = true;
    try {
      final allData = await _repository.getTransactions();

      // We always calculate active days from ALL history for the mindfulness grid
      final allUniqueDates = <String>{};
      for (var t in allData) {
        allUniqueDates.add(DateFormat('yyyy-MM-dd').format(t.date));
      }
      activeDays.assignAll(
        allUniqueDates.map((d) => DateTime.parse(d)).toList(),
      );

      var filteredData = allData;

      // Filter by date range
      filteredData = filteredData.where((t) {
        return t.date.isAfter(
              startDate.value.subtract(const Duration(seconds: 1)),
            ) &&
            t.date.isBefore(endDate.value.add(const Duration(days: 1)));
      }).toList();

      // Sort by date descending
      filteredData.sort((a, b) => b.date.compareTo(a.date));
      transactions.assignAll(filteredData);
      calculateSummary();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load transactions');
    } finally {
      isLoading.value = false;
    }
  }

  void calculateSummary() {
    double totalIncome = 0;
    double totalExpenses = 0;

    for (var t in transactions) {
      if (t.isIncome) {
        totalIncome += t.amount;
      } else {
        totalExpenses += t.amount;
      }
    }

    income.value = totalIncome;
    expenses.value = totalExpenses;
    net.value = totalIncome - totalExpenses;
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _repository.deleteTransaction(id);
      await fetchTransactions();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete transaction');
    }
  }
}
