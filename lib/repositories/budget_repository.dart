import 'package:sqflite_orm/sqflite_orm.dart';
import '../models/budget.dart';

class BudgetRepository {
  final DatabaseManager _db;

  BudgetRepository(this._db);

  // Create budget
  Future<Budget> createBudget(Budget budget) async {
    return await _db.query<Budget>().create(budget.toMap());
  }

  // Get all budgets
  Future<List<Budget>> getAllBudgets() async {
    return await _db.query<Budget>().findAll();
  }

  // Get budget by ID
  Future<Budget?> getBudgetById(int id) async {
    return await _db.query<Budget>().findByPk(id);
  }

  // Get budget by category
  Future<Budget?> getBudgetByCategory(int categoryId) async {
    return await _db.query<Budget>()
        .whereClause(WhereClause().equals('categoryId', categoryId))
        .findOne();
  }

  // Get budgets for current month
  Future<List<Budget>> getBudgetsForPeriod(DateTime month) async {
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);
    return await _db.query<Budget>()
        .whereClause(WhereClause()
            .greaterThanOrEqual('createdAt', startDate.toIso8601String())
            .lessThanOrEqual('createdAt', endDate.toIso8601String()))
        .findAll();
  }

  // Update budget
  Future<int> updateBudget(Budget budget) async {
    return await _db.query<Budget>().update(budget);
  }

  // Delete budget
  Future<int> deleteBudget(int id) async {
    return await _db.query<Budget>()
        .whereClause(WhereClause().equals('id', id))
        .delete();
  }

  // Delete budget by category
  Future<int> deleteBudgetByCategory(int categoryId) async {
    return await _db.query<Budget>()
        .whereClause(WhereClause().equals('categoryId', categoryId))
        .delete();
  }
}

