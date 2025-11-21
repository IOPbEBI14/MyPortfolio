import 'base_model.dart';
import 'shopping_item_model.dart';
import 'shopping_list_invite_model.dart';

class ShoppingListModel extends BaseModel {
  final String name;
  final String? description;
  final String ownerId;
  final List<String> memberIds;
  final List<ShoppingItemModel> items;
  final List<ShoppingListInviteModel> pendingInvites;
  
  ShoppingListModel({
    required super.id,
    required this.name,
    this.description,
    required this.ownerId,
    List<String>? memberIds,
    List<ShoppingItemModel>? items,
    List<ShoppingListInviteModel>? pendingInvites,
    required super.createdAt,
    required super.updatedAt,
  })  : memberIds = memberIds ?? [],
        items = items ?? [],
        pendingInvites = pendingInvites ?? [];
  
  int get totalItems => items.length;
  
  int get completedItems => items.where((item) => item.isCompleted).length;
  
  bool get isEmpty => items.isEmpty;
  
  factory ShoppingListModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ownerId: json['ownerId'],
      memberIds: List<String>.from(json['memberIds'] ?? []),
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => ShoppingItemModel.fromJson(item))
          .toList() ?? [],
      pendingInvites: (json['pendingInvites'] as List<dynamic>?)
          ?.map((invite) => ShoppingListInviteModel.fromJson(invite))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'items': items.map((item) => item.toJson()).toList(),
      'pendingInvites': pendingInvites.map((invite) => invite.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  ShoppingListModel copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    List<String>? memberIds,
    List<ShoppingItemModel>? items,
    List<ShoppingListInviteModel>? pendingInvites,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      items: items ?? this.items,
      pendingInvites: pendingInvites ?? this.pendingInvites,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

