import 'package:equatable/equatable.dart';
import 'shopping_item.dart';

class ShoppingList extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final List<String> memberIds;
  final List<ShoppingItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const ShoppingList({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    this.memberIds = const [],
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });
  
  int get totalItems => items.length;
  
  int get completedItems => items.where((item) => item.isCompleted).length;
  
  bool get isEmpty => items.isEmpty;
  
  @override
  List<Object?> get props => [
        id,
        name,
        description,
        ownerId,
        memberIds,
        items,
        createdAt,
        updatedAt,
      ];
}

