import 'package:equatable/equatable.dart';
import '../../models/budget.dart';

class BudgetState extends Equatable {
  final List<Budget> budgets;
  final bool isLoading;
  final String? error;

  const BudgetState({
    this.budgets = const [],
    this.isLoading = false,
    this.error,
  });

  BudgetState copyWith({
    List<Budget>? budgets,
    bool? isLoading,
    String? error,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [budgets, isLoading, error];
}

