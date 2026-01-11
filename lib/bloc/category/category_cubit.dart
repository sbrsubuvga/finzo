import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/locator_service.dart';
import '../../repositories/category_repository.dart';
import '../../models/category.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _categoryRepo = get<CategoryRepository>();

  CategoryCubit() : super(const CategoryState()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final categories = await _categoryRepo.getAllCategories();
      final incomeCategories = categories.where((c) => c.type == 'income').toList();
      final expenseCategories = categories.where((c) => c.type == 'expense').toList();
      
      emit(state.copyWith(
        categories: categories,
        incomeCategories: incomeCategories,
        expenseCategories: expenseCategories,
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

  Future<void> addCategory(Category category) async {
    try {
      await _categoryRepo.createCategory(category);
      await loadCategories();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _categoryRepo.updateCategory(category);
      await loadCategories();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _categoryRepo.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Category? getCategoryById(int id) {
    try {
      return state.categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}

