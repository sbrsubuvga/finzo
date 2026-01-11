import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/budget/budget_cubit.dart';
import '../../bloc/budget/budget_state.dart';
import '../../bloc/category/category_cubit.dart';
import '../../bloc/category/category_state.dart';
import '../../bloc/transaction/transaction_cubit.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBudgetDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<BudgetCubit, BudgetState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No budgets set',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showAddBudgetDialog(context),
                    child: const Text('Create Budget'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: state.budgets.map((budget) {
              return FutureBuilder<Category?>(
                future: _getCategory(budget.categoryId),
                builder: (context, snapshot) {
                  final category = snapshot.data;
                  return FutureBuilder<double>(
                    future: _getSpentAmount(budget.categoryId),
                    builder: (context, spentSnapshot) {
                      final spent = spentSnapshot.data ?? 0.0;
                      final percentage = budget.amount > 0
                          ? ((spent / budget.amount) * 100).clamp(0.0, 100.0)
                          : 0.0;
                      final isOverBudget = spent > budget.amount;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (category != null)
                                    Text(
                                      category.icon,
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          category?.name ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Budget: ${Helpers.formatCurrency(budget.amount)}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _showDeleteDialog(context, context.read<BudgetCubit>(), budget);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isOverBudget ? Colors.red : Colors.green,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Spent: ${Helpers.formatCurrency(spent)}',
                                    style: TextStyle(
                                      color: isOverBudget ? Colors.red : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: isOverBudget ? Colors.red : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (isOverBudget)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Over budget by ${Helpers.formatCurrency(spent - budget.amount)}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Future<Category?> _getCategory(int categoryId) async {
    final categoryCubit = context.read<CategoryCubit>();
    return categoryCubit.getCategoryById(categoryId);
  }

  Future<double> _getSpentAmount(int categoryId) async {
    final transactionCubit = context.read<TransactionCubit>();
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    final transactions = await transactionCubit.getTransactionsByCategory(categoryId);
    final monthlyTransactions = transactions.where((t) =>
        t.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
        t.date.isBefore(endOfMonth.add(const Duration(days: 1))) &&
        t.type == AppConstants.transactionTypeExpense).toList();
    
    return monthlyTransactions.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  void _showAddBudgetDialog(BuildContext context) {
    final amountController = TextEditingController();
    Category? selectedCategory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Budget'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, categoryState) {
                    final expenseCategories = categoryState.expenseCategories;
                    return DropdownButtonFormField<Category>(
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: expenseCategories.map<DropdownMenuItem<Category>>((category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Row(
                            children: [
                              Text(category.icon),
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (category) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Budget Amount',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedCategory != null &&
                    amountController.text.isNotEmpty) {
                  final amount = double.tryParse(amountController.text);
                  if (amount != null && amount > 0) {
                    final budget = Budget(
                      categoryId: selectedCategory!.id!,
                      amount: amount,
                      period: AppConstants.periodMonthly,
                      createdAt: DateTime.now(),
                    );
                    final budgetCubit = context.read<BudgetCubit>();
                    budgetCubit.addBudget(budget).then((_) {
                      Navigator.pop(context);
                    });
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    BudgetCubit cubit,
    Budget budget,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cubit.deleteBudget(budget.id!).then((_) {
                Navigator.pop(context);
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

