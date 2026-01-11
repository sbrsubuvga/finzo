import 'package:sqflite_orm/sqflite_orm.dart';

@Table(name: 'transactions')
class Transaction extends BaseModel {
  @PrimaryKey()
  @Column(name: 'id')
  int? id;

  @Column(name: 'amount')
  double amount;

  @Column(name: 'type')
  String type; // 'income' or 'expense'

  @ForeignKey(table: 'categories', column: 'id')
  @Column(name: 'categoryId')
  int categoryId;

  @Column(name: 'date')
  DateTime date;

  @Column(name: 'description')
  String? description;

  @Column(name: 'paymentMethod')
  String? paymentMethod;

  @Column(name: 'createdAt')
  DateTime createdAt;

  @Column(name: 'updatedAt')
  DateTime updatedAt;

  Transaction({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.description,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'description': description,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  BaseModel fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      categoryId: map['categoryId'] as int,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String?,
      paymentMethod: map['paymentMethod'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  String get tableName => 'transactions';

  // JSON serialization for backup
  Map<String, dynamic> toJson() => toMap();

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int?,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      categoryId: json['categoryId'] as int,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

