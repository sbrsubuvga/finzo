import 'package:get_it/get_it.dart';
import 'package:sqflite_orm/sqflite_orm.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/budget_repository.dart';
import '../repositories/dashboard_repository.dart';
import '../services/database_service.dart';
import 'backup_service.dart';
import 'google_drive_service.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // Initialize and register DatabaseManager
  final db = await DatabaseService.database;
  getIt.registerSingleton<DatabaseManager>(db);

  // Register Repositories
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepository(getIt<DatabaseManager>()),
  );

  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepository(getIt<DatabaseManager>()),
  );

  getIt.registerLazySingleton<BudgetRepository>(
    () => BudgetRepository(getIt<DatabaseManager>()),
  );

  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepository(
      getIt<TransactionRepository>(),
      getIt<CategoryRepository>(),
    ),
  );

  // Register Services
  getIt.registerLazySingleton<BackupService>(
    () => BackupService(
      getIt<TransactionRepository>(),
      getIt<CategoryRepository>(),
      getIt<BudgetRepository>(),
    ),
  );

  getIt.registerLazySingleton<GoogleDriveService>(
    () => GoogleDriveService(),
  );

  // Initialize default categories if needed
  final categoryRepo = getIt<CategoryRepository>();
  if (!(await categoryRepo.hasDefaultCategories())) {
    await categoryRepo.createDefaultCategories();
  }
}

// Helper function to get registered instances
T get<T extends Object>() => getIt<T>();

