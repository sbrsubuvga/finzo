import 'package:equatable/equatable.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';

class DashboardState extends Equatable {
  final double currentBalance;
  final Map<String, double> monthlySummary;
  final Map<Category, double> categorySpending;
  final List<Transaction> recentTransactions;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.currentBalance = 0.0,
    this.monthlySummary = const {},
    this.categorySpending = const {},
    this.recentTransactions = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    double? currentBalance,
    Map<String, double>? monthlySummary,
    Map<Category, double>? categorySpending,
    List<Transaction>? recentTransactions,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      currentBalance: currentBalance ?? this.currentBalance,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      categorySpending: categorySpending ?? this.categorySpending,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        currentBalance,
        monthlySummary,
        categorySpending,
        recentTransactions,
        isLoading,
        error,
      ];
}

