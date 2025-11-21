import 'base_model.dart';

class PurchaseHistoryModel extends BaseModel {
  final String itemName;
  final String? category;
  final int quantity;
  final DateTime purchasedAt;
  final String listId;
  final String purchasedByUserId;
  
  PurchaseHistoryModel({
    required super.id,
    required this.itemName,
    this.category,
    required this.quantity,
    required this.purchasedAt,
    required this.listId,
    required this.purchasedByUserId,
    required super.createdAt,
    required super.updatedAt,
  });
  
  factory PurchaseHistoryModel.fromJson(Map<String, dynamic> json) {
    return PurchaseHistoryModel(
      id: json['id'],
      itemName: json['itemName'],
      category: json['category'],
      quantity: json['quantity'],
      purchasedAt: DateTime.parse(json['purchasedAt']),
      listId: json['listId'],
      purchasedByUserId: json['purchasedByUserId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'category': category,
      'quantity': quantity,
      'purchasedAt': purchasedAt.toIso8601String(),
      'listId': listId,
      'purchasedByUserId': purchasedByUserId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

