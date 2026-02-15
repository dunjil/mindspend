import 'package:sqflite/sqflite.dart';
import '../../../../core/services/database_helper.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/repositories/transaction_repository.dart';

class LocalTransactionRepository implements TransactionRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'transactions',
      transaction.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final db = await _databaseHelper.database;
    await db.update(
      'transactions',
      transaction.toJson(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');

    return List.generate(maps.length, (i) {
      return TransactionModel.fromJson(maps[i]);
    });
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _databaseHelper.database;

    // Normalize dates to start and end of days
    final startDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return TransactionModel.fromJson(maps[i]);
    });
  }
}
