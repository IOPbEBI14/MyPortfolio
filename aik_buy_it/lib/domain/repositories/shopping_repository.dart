import 'dart:async';
import '../entities/shopping_list.dart';
import '../entities/shopping_item.dart';
import '../entities/list_permission.dart';

abstract class ShoppingRepository {
  // Синхронные методы
  Future<List<ShoppingList>> getAllLists();
  Future<ShoppingList?> getListById(String id);
  Future<ShoppingList> createList(String name, String? description, String ownerId);
  Future<ShoppingList> updateList(ShoppingList list);
  Future<void> deleteList(String id);
  
  // Stream методы для live-обновлений
  Stream<List<ShoppingList>> watchAllLists();
  Stream<ShoppingList?> watchListById(String id);
  
  // Работа с элементами
  Future<ShoppingItem> addItem(String listId, ShoppingItem item);
  Future<ShoppingItem> updateItem(String listId, ShoppingItem item);
  Future<void> deleteItem(String listId, String itemId);
  Future<void> toggleItemCompletion(String listId, String itemId);
  
  // Приглашения
  Future<void> sendInvite(String listId, String email, String invitedByUserId);
  Future<void> acceptInvite(String inviteId, String userId);
  Future<void> rejectInvite(String inviteId);
  
  // Разрешения
  Future<ListPermission> getUserPermission(String listId, String userId);
  Future<void> updateMemberPermission(String listId, String userId, ListPermission permission);
  
  // Синхронизация
  Future<void> syncWithRemote();
}

