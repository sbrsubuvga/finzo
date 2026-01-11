import 'package:sqflite_orm/sqflite_orm.dart';

@Table(name: 'categories')
class Category extends BaseModel {
  @PrimaryKey()
  @Column(name: 'id')
  int? id;

  @Column(name: 'name')
  String name;

  @Column(name: 'type')
  String type; // 'income' or 'expense'

  @Column(name: 'icon')
  String icon;

  @Column(name: 'color')
  String color;

  @Column(name: 'isDefault')
  bool isDefault;

  Category({
    this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.isDefault = false,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'isDefault': isDefault ? 1 : 0,
    };
  }

  @override
  BaseModel fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      icon: map['icon'] as String,
      color: map['color'] as String,
      isDefault: (map['isDefault'] as int) == 1,
    );
  }

  @override
  String get tableName => 'categories';

  // JSON serialization for backup
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'icon': icon,
        'color': color,
        'isDefault': isDefault,
      };

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int?,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      isDefault: json['isDefault'] as bool,
    );
  }
}

