import 'package:flutter/material.dart';
import '../models/category.dart';
import '../utils/helpers.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    Key? key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Color(Helpers.parseColor(category.color));

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.icon),
          const SizedBox(width: 4),
          Text(category.name),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap?.call(),
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color.withOpacity(0.3),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

