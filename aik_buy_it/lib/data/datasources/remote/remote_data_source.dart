import 'dart:async';
import 'package:aik_buy_it/data/models/shopping_list_model.dart';

abstract class RemoteDataSource {
  Stream<List<ShoppingListModel>> watchAllLists();
  Future<List<ShoppingListModel>> getAllLists();
  Future<ShoppingListModel?> getListById(String id);
  Future<ShoppingListModel> saveList(ShoppingListModel list);
  Future<void> deleteList(String id);
  
  // Приглашения
  Future<void> sendInvite(String listId, String email, String invitedByUserId);
  Future<void> acceptInvite(String inviteId, String userId);
  Future<void> rejectInvite(String inviteId);
  
  // Разрешения
  Future<void> updateMemberPermission(String listId, String userId, String permission);
}

