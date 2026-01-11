import 'transaction.dart';
import 'category.dart';
import 'budget.dart';

class BackupData {
  final List<Transaction> transactions;
  final List<Category> categories;
  final List<Budget> budgets;
  final DateTime backupDate;
  final String appVersion;

  BackupData({
    required this.transactions,
    required this.categories,
    required this.budgets,
    required this.backupDate,
    this.appVersion = '1.0.0',
  });

  Map<String, dynamic> toJson() {
    return {
      'appVersion': appVersion,
      'backupDate': backupDate.toIso8601String(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'budgets': budgets.map((b) => b.toJson()).toList(),
    };
  }

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      appVersion: json['appVersion'] as String? ?? '1.0.0',
      backupDate: DateTime.parse(json['backupDate'] as String),
      transactions: (json['transactions'] as List<dynamic>)
          .map((t) => Transaction.fromJson(t as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>)
          .map((c) => Category.fromJson(c as Map<String, dynamic>))
          .toList(),
      budgets: (json['budgets'] as List<dynamic>)
          .map((b) => Budget.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }
}

