import '../models/transaction.dart';
import '../models/category.dart';
import 'transaction_repository.dart';
import 'category_repository.dart';

class DashboardRepository {
  final TransactionRepository _transactionRepo;
  final CategoryRepository _categoryRepo;

  DashboardRepository(this._transactionRepo, this._categoryRepo);

  // Get current balance
  Future<double> getCurrentBalance() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final income = await _transactionRepo.getTotalByTypeAndPeriod(
        'income', startOfMonth, endOfMonth);
    final expenses = await _transactionRepo.getTotalByTypeAndPeriod(
        'expense', startOfMonth, endOfMonth);

    return income - expenses;
  }

  // Get monthly summary
  Future<Map<String, double>> getMonthlySummary(DateTime month) async {
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);

    final income = await _transactionRepo.getTotalByTypeAndPeriod(
        'income', startDate, endDate);
    final expenses = await _transactionRepo.getTotalByTypeAndPeriod(
        'expense', startDate, endDate);

    return {
      'income': income,
      'expenses': expenses,
      'balance': income - expenses,
    };
  }

  // Get category-wise spending
  Future<Map<Category, double>> getCategorySpending(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final transactions = await _transactionRepo.getTransactionsByDateRange(
        startDate, endDate);
    final categories = await _categoryRepo.getCategoriesByType('expense');

    final Map<Category, double> spending = {};
    for (var category in categories) {
      final categoryTransactions = transactions
          .where((t) => t.categoryId == category.id && t.type == 'expense');
      final total = categoryTransactions.fold(
          0.0, (sum, t) => sum + t.amount);
      if (total > 0) {
        spending[category] = total;
      }
    }

    return spending;
  }

  // Get recent transactions
  Future<List<Transaction>> getRecentTransactions({int limit = 10}) async {
    final all = await _transactionRepo.getAllTransactions();
    return all.take(limit).toList();
  }

  // Get total income for period
  Future<double> getTotalIncome(DateTime startDate, DateTime endDate) async {
    return await _transactionRepo.getTotalByTypeAndPeriod(
        'income', startDate, endDate);
  }

  // Get total expenses for period
  Future<double> getTotalExpenses(DateTime startDate, DateTime endDate) async {
    return await _transactionRepo.getTotalByTypeAndPeriod(
        'expense', startDate, endDate);
  }

  // Get transactions by month
  Future<List<Transaction>> getTransactionsByMonth(DateTime month) async {
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);
    return await _transactionRepo.getTransactionsByDateRange(startDate, endDate);
  }
}

