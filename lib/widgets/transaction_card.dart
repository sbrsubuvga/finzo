import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final Category? category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionCard({
    Key? key,
    required this.transaction,
    this.category,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == AppConstants.transactionTypeIncome;
    final color = isIncome ? Colors.green : Colors.red;
    final icon = category?.icon ?? (isIncome ? '💰' : '💸');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          category?.name ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.description != null && transaction.description!.isNotEmpty)
              Text(transaction.description!),
            Text(
              Helpers.formatDate(transaction.date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${Helpers.formatCurrency(transaction.amount)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: onDelete,
                color: Colors.red,
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

