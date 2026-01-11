import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/category/category_cubit.dart';
import '../../bloc/category/category_state.dart';
import '../../models/category.dart';
import '../../utils/constants.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({Key? key}) : super(key: key);

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  String _selectedType = AppConstants.transactionTypeExpense;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Expenses'),
              Tab(text: 'Income'),
            ],
            onTap: (index) {
              setState(() {
                _selectedType = index == 0
                    ? AppConstants.transactionTypeExpense
                    : AppConstants.transactionTypeIncome;
              });
            },
          ),
        ),
        body: BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final categories = _selectedType == AppConstants.transactionTypeExpense
                ? state.expenseCategories
                : state.incomeCategories;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...categories.map((category) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(int.parse(
                          category.color.replaceAll('#', '0xFF'),
                        )).withOpacity(0.1),
                        child: Text(
                          category.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      title: Text(category.name),
                      subtitle: category.isDefault
                          ? const Text('Default Category')
                          : null,
                      trailing: category.isDefault
                          ? null
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditCategoryDialog(context, context.read<CategoryCubit>(), category);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _showDeleteDialog(context, context.read<CategoryCubit>(), category);
                                  },
                                ),
                              ],
                            ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddCategoryDialog(context, context.read<CategoryCubit>());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Custom Category'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, CategoryCubit cubit) {
    final nameController = TextEditingController();
    final iconController = TextEditingController();
    String selectedColor = '#FF6B6B';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: iconController,
                  decoration: const InputDecoration(
                    labelText: 'Icon (Emoji)',
                    hintText: '🍔',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Color'),
                Wrap(
                  spacing: 8,
                  children: [
                    '#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A',
                    '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E2',
                  ].map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(int.parse(color.replaceAll('#', '0xFF'))),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color
                                ? Colors.black
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
                if (nameController.text.isNotEmpty &&
                    iconController.text.isNotEmpty) {
                  final category = Category(
                    name: nameController.text,
                    type: _selectedType,
                    icon: iconController.text,
                    color: selectedColor,
                    isDefault: false,
                  );
                  cubit.addCategory(category).then((_) {
                    Navigator.pop(context);
                  });
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    CategoryCubit cubit,
    Category category,
  ) {
    final nameController = TextEditingController(text: category.name);
    final iconController = TextEditingController(text: category.icon);
    String selectedColor = category.color;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: iconController,
                  decoration: const InputDecoration(
                    labelText: 'Icon (Emoji)',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Color'),
                Wrap(
                  spacing: 8,
                  children: [
                    '#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A',
                    '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E2',
                  ].map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(int.parse(color.replaceAll('#', '0xFF'))),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color
                                ? Colors.black
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
                if (nameController.text.isNotEmpty &&
                    iconController.text.isNotEmpty) {
                  final updatedCategory = Category(
                    id: category.id,
                    name: nameController.text,
                    type: category.type,
                    icon: iconController.text,
                    color: selectedColor,
                    isDefault: category.isDefault,
                  );
                  cubit.updateCategory(updatedCategory).then((_) {
                    Navigator.pop(context);
                  });
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    CategoryCubit cubit,
    Category category,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text(
          'Are you sure you want to delete this category? Transactions using this category will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cubit.deleteCategory(category.id!).then((_) {
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

