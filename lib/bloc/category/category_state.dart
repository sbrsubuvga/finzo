import 'package:equatable/equatable.dart';
import '../../models/category.dart';

class CategoryState extends Equatable {
  final List<Category> categories;
  final List<Category> incomeCategories;
  final List<Category> expenseCategories;
  final bool isLoading;
  final String? error;

  const CategoryState({
    this.categories = const [],
    this.incomeCategories = const [],
    this.expenseCategories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoryState copyWith({
    List<Category>? categories,
    List<Category>? incomeCategories,
    List<Category>? expenseCategories,
    bool? isLoading,
    String? error,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      incomeCategories: incomeCategories ?? this.incomeCategories,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [categories, incomeCategories, expenseCategories, isLoading, error];
}

