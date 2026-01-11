import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/locator_service.dart';
import '../../repositories/transaction_repository.dart';
import '../../models/transaction.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _transactionRepo = get<TransactionRepository>();

  TransactionCubit() : super(const TransactionState()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final transactions = await _transactionRepo.getAllTransactions();
      emit(state.copyWith(
        transactions: transactions,
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

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _transactionRepo.createTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _transactionRepo.updateTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _transactionRepo.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<List<Transaction>> searchTransactions(String query) async {
    try {
      return await _transactionRepo.searchTransactions(query);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return [];
    }
  }

  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _transactionRepo.getTransactionsByDateRange(startDate, endDate);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return [];
    }
  }

  Future<List<Transaction>> getTransactionsByType(String type) async {
    try {
      return await _transactionRepo.getTransactionsByType(type);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return [];
    }
  }

  Future<List<Transaction>> getTransactionsByCategory(int categoryId) async {
    try {
      return await _transactionRepo.getTransactionsByCategory(categoryId);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return [];
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}

