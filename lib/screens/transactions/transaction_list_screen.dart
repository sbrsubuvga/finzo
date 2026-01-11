import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/transaction/transaction_cubit.dart';
import '../../bloc/transaction/transaction_state.dart';
import '../../bloc/category/category_cubit.dart';
import '../../widgets/transaction_card.dart';
import '../../models/transaction.dart';
import '../../utils/constants.dart';
import 'add_edit_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          // Transaction List
          Expanded(
            child: BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<Transaction> transactions = state.transactions;

                // Apply search filter
                if (_searchController.text.isNotEmpty) {
                  transactions = transactions
                      .where((t) => t.description
                              ?.toLowerCase()
                              .contains(_searchController.text.toLowerCase()) ??
                          false)
                      .toList();
                }

                // Apply type filter
                if (_selectedType != 'all') {
                  transactions = transactions
                      .where((t) => t.type == _selectedType)
                      .toList();
                }

                // Apply date filter
                if (_startDate != null && _endDate != null) {
                  transactions = transactions
                      .where((t) =>
                          t.date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
                          t.date.isBefore(_endDate!.add(const Duration(days: 1))))
                      .toList();
                }

                if (transactions.isEmpty) {
                  return const Center(
                    child: Text('No transactions found'),
                  );
                }

                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final categoryCubit = context.read<CategoryCubit>();
                    final category = categoryCubit.getCategoryById(transaction.categoryId);

                    return TransactionCard(
                      transaction: transaction,
                      category: category,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditTransactionScreen(
                              transaction: transaction,
                            ),
                          ),
                        ).then((_) {
                          context.read<TransactionCubit>().loadTransactions();
                        });
                      },
                      onDelete: () {
                        _showDeleteDialog(context, context.read<TransactionCubit>(), transaction);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditTransactionScreen(),
            ),
          ).then((_) {
            context.read<TransactionCubit>().loadTransactions();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: AppConstants.transactionTypeIncome, child: Text('Income')),
                DropdownMenuItem(value: AppConstants.transactionTypeExpense, child: Text('Expense')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value ?? 'all';
                });
                Navigator.pop(context);
                _showFilterDialog();
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start Date'),
              subtitle: Text(_startDate == null
                  ? 'Not set'
                  : _startDate!.toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _startDate = date;
                  });
                  Navigator.pop(context);
                  _showFilterDialog();
                }
              },
            ),
            ListTile(
              title: const Text('End Date'),
              subtitle: Text(_endDate == null
                  ? 'Not set'
                  : _endDate!.toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? DateTime.now(),
                  firstDate: _startDate ?? DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _endDate = date;
                  });
                  Navigator.pop(context);
                  _showFilterDialog();
                }
              },
            ),
            if (_startDate != null || _endDate != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Clear Date Filter'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = 'all';
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    TransactionCubit cubit,
    Transaction transaction,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await cubit.deleteTransaction(transaction.id!);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction deleted')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

