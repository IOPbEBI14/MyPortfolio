import 'base_model.dart';

enum InviteStatus {
  pending,
  accepted,
  rejected,
  expired,
}

class ShoppingListInviteModel extends BaseModel {
  final String listId;
  final String invitedEmail;
  final String invitedByUserId;
  final InviteStatus status;
  final String? token;
  
  ShoppingListInviteModel({
    required super.id,
    required this.listId,
    required this.invitedEmail,
    required this.invitedByUserId,
    this.status = InviteStatus.pending,
    this.token,
    required super.createdAt,
    required super.updatedAt,
  });
  
  factory ShoppingListInviteModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListInviteModel(
      id: json['id'],
      listId: json['listId'],
      invitedEmail: json['invitedEmail'],
      invitedByUserId: json['invitedByUserId'],
      status: InviteStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InviteStatus.pending,
      ),
      token: json['token'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listId': listId,
      'invitedEmail': invitedEmail,
      'invitedByUserId': invitedByUserId,
      'status': status.name,
      'token': token,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

