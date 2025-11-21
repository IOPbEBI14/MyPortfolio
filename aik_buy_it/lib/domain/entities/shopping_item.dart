import 'package:equatable/equatable.dart';

class ShoppingItem extends Equatable {
  final String id;
  final String name;
  final int quantity;
  final String? category;
  final bool isCompleted;
  final String? notes;
  final String? addedByUserId;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const ShoppingItem({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.category,
    this.isCompleted = false,
    this.notes,
    this.addedByUserId,
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  List<Object?> get props => [
        id,
        name,
        quantity,
        category,
        isCompleted,
        notes,
        addedByUserId,
        createdAt,
        updatedAt,
      ];
}

