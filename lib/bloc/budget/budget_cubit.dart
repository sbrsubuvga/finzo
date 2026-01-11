import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/locator_service.dart';
import '../../repositories/budget_repository.dart';
import '../../models/budget.dart';
import 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final BudgetRepository _budgetRepo = get<BudgetRepository>();

  BudgetCubit() : super(const BudgetState()) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final budgets = await _budgetRepo.getAllBudgets();
      emit(state.copyWith(
        budgets: budgets,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> addBudget(Budget budget) async {
    try {
      await _budgetRepo.createBudget(budget);
      await loadBudgets();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      await _budgetRepo.updateBudget(budget);
      await loadBudgets();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      await _budgetRepo.deleteBudget(id);
      await loadBudgets();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<Budget?> getBudgetByCategory(int categoryId) async {
    try {
      return await _budgetRepo.getBudgetByCategory(categoryId);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return null;
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}

