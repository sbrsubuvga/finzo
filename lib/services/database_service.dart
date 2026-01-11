import 'package:sqflite_orm/sqflite_orm.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/budget.dart';

class DatabaseService {
  static DatabaseManager? _databaseManager;

  static Future<DatabaseManager> get database async {
    if (_databaseManager != null) {
      return _databaseManager!;
    }
    _databaseManager = await _initDatabase();
    return _databaseManager!;
  }

  static Future<DatabaseManager> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = '${documentsDirectory.path}/finzo.db';

    final db = await DatabaseManager.initialize(
      path: path,
      version: 1,
      models: [Transaction, Category, Budget],
      instanceCreators: {
        Transaction: () => Transaction(
              amount: 0,
              type: '',
              categoryId: 0,
              date: DateTime.now(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
        Category: () => Category(
              name: '',
              type: '',
              icon: '',
              color: '',
            ),
        Budget: () => Budget(
              categoryId: 0,
              amount: 0,
              createdAt: DateTime.now(),
            ),
      },
      // Enable Web UI for development
      webDebug: true,
      webDebugPort: 4800,
    );

    return db;
  }

  static Future<void> closeDatabase() async {
    if (_databaseManager != null) {
      // DatabaseManager doesn't have a close method in sqflite_orm
      // The database will be closed automatically when the app closes
      _databaseManager = null;
    }
  }
}

