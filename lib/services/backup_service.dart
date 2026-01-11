import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/backup_data.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/budget_repository.dart';

class BackupService {
  final TransactionRepository _transactionRepo;
  final CategoryRepository _categoryRepo;
  final BudgetRepository _budgetRepo;

  BackupService(
    this._transactionRepo,
    this._categoryRepo,
    this._budgetRepo,
  );

  // Export all data to JSON
  Future<String> exportToJson() async {
    final transactions = await _transactionRepo.getAllTransactions();
    final categories = await _categoryRepo.getAllCategories();
    final budgets = await _budgetRepo.getAllBudgets();

    final backupData = BackupData(
      transactions: transactions,
      categories: categories,
      budgets: budgets,
      backupDate: DateTime.now(),
    );

    return jsonEncode(backupData.toJson());
  }

  // Save backup to file
  Future<File> saveBackupToFile() async {
    final jsonData = await exportToJson();
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${directory.path}/finzo_backup_$timestamp.json');
    await file.writeAsString(jsonData);
    return file;
  }

  // Share backup file
  Future<void> shareBackup() async {
    final file = await saveBackupToFile();
    await Share.shareXFiles([XFile(file.path)], text: 'Finzo Backup');
  }

  // Import from JSON string
  Future<void> importFromJson(String jsonString) async {
    try {
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final backupData = BackupData.fromJson(jsonData);

      // Import categories first (they're referenced by transactions and budgets)
      for (var category in backupData.categories) {
        // Check if category already exists
        final existing = await _categoryRepo.getCategoryById(category.id ?? 0);
        if (existing == null) {
          await _categoryRepo.createCategory(category);
        }
      }

      // Import transactions
      for (var transaction in backupData.transactions) {
        // Check if transaction already exists
        final existing = await _transactionRepo.getTransactionById(transaction.id ?? 0);
        if (existing == null) {
          await _transactionRepo.createTransaction(transaction);
        }
      }

      // Import budgets
      for (var budget in backupData.budgets) {
        // Check if budget already exists
        final existing = await _budgetRepo.getBudgetById(budget.id ?? 0);
        if (existing == null) {
          await _budgetRepo.createBudget(budget);
        }
      }
    } catch (e) {
      throw Exception('Failed to import backup: $e');
    }
  }

  // Import from file
  Future<void> importFromFile(File file) async {
    final jsonString = await file.readAsString();
    await importFromJson(jsonString);
  }

  // Validate backup file
  Future<bool> validateBackupFile(File file) async {
    try {
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Check required fields
      if (!jsonData.containsKey('transactions') ||
          !jsonData.containsKey('categories') ||
          !jsonData.containsKey('budgets')) {
        return false;
      }

      // Try to parse as BackupData
      BackupData.fromJson(jsonData);
      return true;
    } catch (e) {
      return false;
    }
  }
}

