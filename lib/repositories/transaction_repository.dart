import 'package:sqflite_orm/sqflite_orm.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final DatabaseManager _db;

  TransactionRepository(this._db);

  // Create transaction
  Future<Transaction> createTransaction(Transaction transaction) async {
    return await _db.query<Transaction>().create(transaction.toMap());
  }

  // Get all transactions
  Future<List<Transaction>> getAllTransactions() async {
    return await _db.query<Transaction>()
        .orderBy('date', descending: true)
        .findAll();
  }

  // Get transaction by ID
  Future<Transaction?> getTransactionById(int id) async {
    return await _db.query<Transaction>().findByPk(id);
  }

  // Get transactions by type
  Future<List<Transaction>> getTransactionsByType(String type) async {
    return await _db.query<Transaction>()
        .whereClause(WhereClause().equals('type', type))
        .orderBy('date', descending: true)
        .findAll();
  }

  // Get transactions by date range
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _db.query<Transaction>()
        .whereClause(WhereClause()
            .greaterThanOrEqual('date', startDate.toIso8601String())
            .lessThanOrEqual('date', endDate.toIso8601String()))
        .orderBy('date', descending: true)
        .findAll();
  }

  // Get transactions by category
  Future<List<Transaction>> getTransactionsByCategory(int categoryId) async {
    return await _db.query<Transaction>()
        .whereClause(WhereClause().equals('categoryId', categoryId))
        .orderBy('date', descending: true)
        .findAll();
  }

  // Search transactions
  Future<List<Transaction>> searchTransactions(String query) async {
    if (query.isEmpty) {
      return await getAllTransactions();
    }
    return await _db.query<Transaction>()
        .whereClause(WhereClause().like('description', '%$query%'))
        .orderBy('date', descending: true)
        .findAll();
  }

  // Update transaction
  Future<int> updateTransaction(Transaction transaction) async {
    transaction.updatedAt = DateTime.now();
    return await _db.query<Transaction>().update(transaction);
  }

  // Delete transaction
  Future<int> deleteTransaction(int id) async {
    return await _db.query<Transaction>()
        .whereClause(WhereClause().equals('id', id))
        .delete();
  }

  // Get total income/expense for period
  Future<double> getTotalByTypeAndPeriod(
    String type,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final transactions = await getTransactionsByDateRange(startDate, endDate);
    final filtered = transactions.where((t) => t.type == type).toList();
    return filtered.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  // Get count of transactions
  Future<int> getTransactionCount() async {
    return await _db.query<Transaction>().count();
  }
}

