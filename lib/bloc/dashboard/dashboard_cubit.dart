import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/locator_service.dart';
import '../../repositories/dashboard_repository.dart';
import '../../models/category.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepo = get<DashboardRepository>();

  DashboardCubit() : super(const DashboardState()) {
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final currentBalance = await _dashboardRepo.getCurrentBalance();
      final monthlySummary = await _dashboardRepo.getMonthlySummary(DateTime.now());
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      final categorySpending = await _dashboardRepo.getCategorySpending(startOfMonth, endOfMonth);
      final recentTransactions = await _dashboardRepo.getRecentTransactions(limit: 10);

      emit(state.copyWith(
        currentBalance: currentBalance,
        monthlySummary: monthlySummary,
        categorySpending: categorySpending,
        recentTransactions: recentTransactions,
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

  Future<void> refresh() async {
    await loadDashboardData();
  }

  Future<Map<String, double>> getMonthlySummaryForDate(DateTime month) async {
    try {
      return await _dashboardRepo.getMonthlySummary(month);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return {};
    }
  }

  Future<Map<Category, double>> getCategorySpendingForPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _dashboardRepo.getCategorySpending(startDate, endDate);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return {};
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}

