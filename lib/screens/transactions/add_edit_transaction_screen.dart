import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/transaction/transaction_cubit.dart';
import '../../bloc/category/category_cubit.dart';
import '../../bloc/category/category_state.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../utils/constants.dart';
import '../../widgets/category_chip.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionScreen({Key? key, this.transaction}) : super(key: key);

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _paymentMethodController = TextEditingController();

  String _selectedType = AppConstants.transactionTypeExpense;
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _amountController.text = t.amount.toString();
      _descriptionController.text = t.description ?? '';
      _paymentMethodController.text = t.paymentMethod ?? '';
      _selectedType = t.type;
      _selectedDate = t.date;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final categoryCubit = context.read<CategoryCubit>();
        _selectedCategory = categoryCubit.getCategoryById(t.categoryId);
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Type Selection
            _buildTypeSelector(),
            const SizedBox(height: 24),
            
            // Category Selection
            _buildCategorySelector(),
            const SizedBox(height: 24),
            
            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Date
            ListTile(
              title: const Text('Date'),
              subtitle: Text(
                '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
              ),
              maxLength: AppConstants.maxDescriptionLength,
            ),
            const SizedBox(height: 24),
            
            // Payment Method
            TextFormField(
              controller: _paymentMethodController,
              decoration: const InputDecoration(
                labelText: 'Payment Method (Optional)',
                hintText: 'Cash, Card, Bank Transfer, etc.',
              ),
            ),
            const SizedBox(height: 32),
            
            // Save Button
            ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Income'),
                selected: _selectedType == AppConstants.transactionTypeIncome,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedType = AppConstants.transactionTypeIncome;
                      _selectedCategory = null;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ChoiceChip(
                label: const Text('Expense'),
                selected: _selectedType == AppConstants.transactionTypeExpense,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedType = AppConstants.transactionTypeExpense;
                      _selectedCategory = null;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        final categories = _selectedType == AppConstants.transactionTypeIncome
            ? state.incomeCategories
            : state.expenseCategories;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) {
                return CategoryChip(
                  category: category,
                  isSelected: _selectedCategory?.id == category.id,
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              }).toList(),
            ),
            if (_selectedCategory == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Please select a category',
                  style: TextStyle(color: Colors.red[700], fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final amount = double.parse(_amountController.text);
    final now = DateTime.now();

    final transaction = Transaction(
      id: widget.transaction?.id,
      amount: amount,
      type: _selectedType,
      categoryId: _selectedCategory!.id!,
      date: _selectedDate,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      paymentMethod: _paymentMethodController.text.isEmpty
          ? null
          : _paymentMethodController.text,
      createdAt: widget.transaction?.createdAt ?? now,
      updatedAt: now,
    );

    final cubit = context.read<TransactionCubit>();
    
    if (widget.transaction == null) {
      cubit.addTransaction(transaction).then((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction added successfully')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      });
    } else {
      cubit.updateTransaction(transaction).then((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction updated successfully')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      });
    }
  }
}

