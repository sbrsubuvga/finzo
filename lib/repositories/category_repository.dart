import 'package:sqflite_orm/sqflite_orm.dart';
import '../models/category.dart';

class CategoryRepository {
  final DatabaseManager _db;

  CategoryRepository(this._db);

  // Create category
  Future<Category> createCategory(Category category) async {
    return await _db.query<Category>().create(category.toMap());
  }

  // Get all categories
  Future<List<Category>> getAllCategories() async {
    return await _db.query<Category>().findAll();
  }

  // Get categories by type
  Future<List<Category>> getCategoriesByType(String type) async {
    return await _db.query<Category>()
        .whereClause(WhereClause().equals('type', type))
        .findAll();
  }

  // Get category by ID
  Future<Category?> getCategoryById(int id) async {
    return await _db.query<Category>().findByPk(id);
  }

  // Update category
  Future<int> updateCategory(Category category) async {
    return await _db.query<Category>().update(category);
  }

  // Delete category
  Future<int> deleteCategory(int id) async {
    return await _db.query<Category>()
        .whereClause(WhereClause().equals('id', id))
        .delete();
  }

  // Check if default categories exist
  Future<bool> hasDefaultCategories() async {
    final categories = await getAllCategories();
    return categories.any((c) => c.isDefault);
  }

  // Create default categories
  Future<void> createDefaultCategories() async {
    if (await hasDefaultCategories()) {
      return; // Already created
    }

    final defaultCategories = [
      // Expense categories
      Category(
        name: 'Food & Dining',
        type: 'expense',
        icon: '🍔',
        color: '#FF6B6B',
        isDefault: true,
      ),
      Category(
        name: 'Transportation',
        type: 'expense',
        icon: '🚗',
        color: '#4ECDC4',
        isDefault: true,
      ),
      Category(
        name: 'Shopping',
        type: 'expense',
        icon: '🛍️',
        color: '#45B7D1',
        isDefault: true,
      ),
      Category(
        name: 'Bills & Utilities',
        type: 'expense',
        icon: '💡',
        color: '#FFA07A',
        isDefault: true,
      ),
      Category(
        name: 'Entertainment',
        type: 'expense',
        icon: '🎬',
        color: '#98D8C8',
        isDefault: true,
      ),
      Category(
        name: 'Health & Fitness',
        type: 'expense',
        icon: '💊',
        color: '#F7DC6F',
        isDefault: true,
      ),
      Category(
        name: 'Education',
        type: 'expense',
        icon: '📚',
        color: '#BB8FCE',
        isDefault: true,
      ),
      Category(
        name: 'Travel',
        type: 'expense',
        icon: '✈️',
        color: '#85C1E2',
        isDefault: true,
      ),
      Category(
        name: 'Personal Care',
        type: 'expense',
        icon: '💅',
        color: '#F8B88B',
        isDefault: true,
      ),
      Category(
        name: 'Others',
        type: 'expense',
        icon: '📦',
        color: '#D5DBDB',
        isDefault: true,
      ),
      // Income categories
      Category(
        name: 'Salary',
        type: 'income',
        icon: '💰',
        color: '#96CEB4',
        isDefault: true,
      ),
      Category(
        name: 'Freelance',
        type: 'income',
        icon: '💼',
        color: '#FFEAA7',
        isDefault: true,
      ),
      Category(
        name: 'Investment',
        type: 'income',
        icon: '📈',
        color: '#74B9FF',
        isDefault: true,
      ),
      Category(
        name: 'Gift',
        type: 'income',
        icon: '🎁',
        color: '#FD79A8',
        isDefault: true,
      ),
      Category(
        name: 'Others',
        type: 'income',
        icon: '💵',
        color: '#A29BFE',
        isDefault: true,
      ),
    ];

    for (var category in defaultCategories) {
      await createCategory(category);
    }
  }
}

