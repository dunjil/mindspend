
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/models/transaction_model.dart';

class MockTransactionRepository implements TransactionRepository {
  final List<TransactionModel> _transactions = [];

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    _transactions.add(transaction);
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_transactions);
  }
}
