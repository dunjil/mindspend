import 'package:get/get.dart';
import '../../../../core/services/export_service.dart';
import '../../../transaction/data/repositories/local_transaction_repository.dart';
import 'package:mindspend/features/profile/presentation/controllers/profile_controller.dart';

class ExportController extends GetxController {
  final ExportService _exportService = ExportService();
  final LocalTransactionRepository _repository = LocalTransactionRepository();
  final RxBool isExporting = false.obs;

  final Rx<DateTime> startDate = DateTime.now()
      .subtract(const Duration(days: 30))
      .obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  Future<void> exportCSV() async {
    try {
      isExporting.value = true;
      final transactions = await _repository.getTransactionsByDateRange(
        startDate.value,
        endDate.value,
      );
      if (transactions.isEmpty) {
        Get.snackbar('No Data', 'No transactions to export.');
        return;
      }
      final currencySymbol = Get.find<ProfileController>().currencySymbol;
      await _exportService.exportToCSV(transactions, currencySymbol);
    } catch (e) {
      Get.snackbar('Error', 'Failed to export CSV: $e');
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> exportPDF() async {
    try {
      isExporting.value = true;
      final transactions = await _repository.getTransactionsByDateRange(
        startDate.value,
        endDate.value,
      );
      if (transactions.isEmpty) {
        Get.snackbar('No Data', 'No transactions to export.');
        return;
      }
      final currencySymbol = Get.find<ProfileController>().currencySymbol;
      await _exportService.exportToPDF(transactions, currencySymbol);
    } catch (e) {
      Get.snackbar('Error', 'Failed to export PDF: $e');
    } finally {
      isExporting.value = false;
    }
  }
}
