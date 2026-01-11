import 'package:sqflite_orm/sqflite_orm.dart';

@Table(name: 'budgets')
class Budget extends BaseModel {
  @PrimaryKey()
  @Column(name: 'id')
  int? id;

  @ForeignKey(table: 'categories', column: 'id')
  @Column(name: 'categoryId')
  int categoryId;

  @Column(name: 'amount')
  double amount;

  @Column(name: 'period')
  String period; // 'monthly', 'weekly', 'yearly'

  @Column(name: 'createdAt')
  DateTime createdAt;

  Budget({
    this.id,
    required this.categoryId,
    required this.amount,
    this.period = 'monthly',
    required this.createdAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'period': period,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  BaseModel fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      categoryId: map['categoryId'] as int,
      amount: (map['amount'] as num).toDouble(),
      period: map['period'] as String? ?? 'monthly',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String get tableName => 'budgets';

  // JSON serialization for backup
  Map<String, dynamic> toJson() => toMap();

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as int?,
      categoryId: json['categoryId'] as int,
      amount: (json['amount'] as num).toDouble(),
      period: json['period'] as String? ?? 'monthly',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

