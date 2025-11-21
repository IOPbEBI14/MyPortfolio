import 'base_model.dart';

class ShoppingItemModel extends BaseModel {
  final String name;
  final int quantity;
  final String? category;
  final bool isCompleted;
  final String? notes;
  final String? addedByUserId;
  
  ShoppingItemModel({
    required super.id,
    required this.name,
    this.quantity = 1,
    this.category,
    this.isCompleted = false,
    this.notes,
    this.addedByUserId,
    required super.createdAt,
    required super.updatedAt,
  });
  
  ShoppingItemModel copyWith({
    String? id,
    String? name,
    int? quantity,
    String? category,
    bool? isCompleted,
    String? notes,
    String? addedByUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      addedByUserId: addedByUserId ?? this.addedByUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  factory ShoppingItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingItemModel(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'] ?? 1,
      category: json['category'],
      isCompleted: json['isCompleted'] ?? false,
      notes: json['notes'],
      addedByUserId: json['addedByUserId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
      'isCompleted': isCompleted,
      'notes': notes,
      'addedByUserId': addedByUserId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

