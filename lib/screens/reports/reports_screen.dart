import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../bloc/transaction/transaction_cubit.dart';
import '../../bloc/category/category_cubit.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadReportData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data ?? {};
          final income = data['income'] ?? 0.0;
          final expenses = data['expenses'] ?? 0.0;
          final categorySpending = data['categorySpending'] ?? <String, double>{};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Range Display
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date Range',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${Helpers.formatDate(_startDate)} - ${Helpers.formatDate(_endDate)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _selectDateRange,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Income vs Expenses Bar Chart
                _buildIncomeExpenseChart(income, expenses),
                const SizedBox(height: 24),
                
                // Category Spending Pie Chart
                if (categorySpending.isNotEmpty)
                  _buildCategoryPieChart(categorySpending),
                const SizedBox(height: 24),
                
                // Summary Cards
                _buildSummaryCards(income, expenses),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadReportData() async {
    final transactionCubit = context.read<TransactionCubit>();

    final transactions = await transactionCubit.getTransactionsByDateRange(
      _startDate,
      _endDate,
    );

    final income = transactions
        .where((t) => t.type == AppConstants.transactionTypeIncome)
        .fold(0.0, (sum, t) => sum + t.amount);

    final expenses = transactions
        .where((t) => t.type == AppConstants.transactionTypeExpense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final categoryCubit = context.read<CategoryCubit>();
    final expenseCategories = categoryCubit.state.expenseCategories;
    final Map<String, double> categorySpending = {};

    for (var category in expenseCategories) {
      final categoryTransactions = transactions
          .where((t) => t.categoryId == category.id && t.type == AppConstants.transactionTypeExpense);
      final total = categoryTransactions.fold(0.0, (sum, t) => sum + t.amount);
      if (total > 0) {
        categorySpending[category.name] = total;
      }
    }

    return {
      'income': income,
      'expenses': expenses,
      'categorySpending': categorySpending,
    };
  }

  Widget _buildIncomeExpenseChart(double income, double expenses) {
    final maxValue = [income, expenses].reduce((a, b) => a > b ? a : b);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Income vs Expenses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxValue * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.grey[800]!,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() == 0) return const Text('Income');
                          if (value.toInt() == 1) return const Text('Expenses');
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(Helpers.formatCurrency(value));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: income,
                          color: Colors.green,
                          width: 40,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: expenses,
                          color: Colors.red,
                          width: 40,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(Map<String, double> categorySpending) {
    final entries = categorySpending.entries.toList();
    final total = categorySpending.values.fold(0.0, (sum, val) => sum + val);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Spending',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: entries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final amount = entry.value.value;
                    final percentage = (amount / total * 100);
                    
                    final colors = [
                      Colors.blue,
                      Colors.green,
                      Colors.orange,
                      Colors.purple,
                      Colors.red,
                      Colors.teal,
                      Colors.pink,
                      Colors.indigo,
                    ];

                    return PieChartSectionData(
                      value: amount,
                      title: '${percentage.toStringAsFixed(1)}%',
                      color: colors[index % colors.length],
                      radius: 80,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...entries.asMap().entries.map((entry) {
              final index = entry.key;
              final categoryName = entry.value.key;
              final amount = entry.value.value;
              final colors = [
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.purple,
                Colors.red,
                Colors.teal,
                Colors.pink,
                Colors.indigo,
              ];

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(categoryName)),
                    Text(
                      Helpers.formatCurrency(amount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(double income, double expenses) {

    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Income',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Helpers.formatCurrency(income),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Expenses',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Helpers.formatCurrency(expenses),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }
}

