import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'remote_data_source.dart';
import 'package:aik_buy_it/data/models/shopping_list_model.dart';
import 'package:aik_buy_it/data/models/shopping_list_invite_model.dart';

/// Mock реализация удаленного хранилища для разработки
/// В продакшене можно заменить на FirebaseRemoteDataSource
class MockRemoteDataSource implements RemoteDataSource {
  // Имитация базы данных в памяти
  final Map<String, ShoppingListModel> _lists = {};
  final Map<String, ShoppingListInviteModel> _invites = {};
  final BehaviorSubject<List<ShoppingListModel>> _listsSubject = 
      BehaviorSubject<List<ShoppingListModel>>.seeded([]);
  
  // Симуляция задержки сети
  Future<T> _simulateNetworkDelay<T>(T result) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return result;
  }
  
  @override
  Stream<List<ShoppingListModel>> watchAllLists() {
    return _listsSubject.stream;
  }
  
  @override
  Future<List<ShoppingListModel>> getAllLists() async {
    return _simulateNetworkDelay(_lists.values.toList());
  }
  
  @override
  Future<ShoppingListModel?> getListById(String id) async {
    return _simulateNetworkDelay(_lists[id]);
  }
  
  @override
  Future<ShoppingListModel> saveList(ShoppingListModel list) async {
    await _simulateNetworkDelay(null);
    _lists[list.id] = list;
    _updateStream();
    return list;
  }
  
  @override
  Future<void> deleteList(String id) async {
    await _simulateNetworkDelay(null);
    _lists.remove(id);
    _updateStream();
  }
  
  @override
  Future<void> sendInvite(String listId, String email, String invitedByUserId) async {
    await _simulateNetworkDelay(null);
    final invite = ShoppingListInviteModel(
      id: 'invite_${DateTime.now().millisecondsSinceEpoch}',
      listId: listId,
      invitedEmail: email,
      invitedByUserId: invitedByUserId,
      status: InviteStatus.pending,
      token: 'token_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _invites[invite.id] = invite;
    
    // Добавляем приглашение в список
    final list = _lists[listId];
    if (list != null) {
      final updatedInvites = [...list.pendingInvites, invite];
      _lists[listId] = list.copyWith(
        pendingInvites: updatedInvites,
        updatedAt: DateTime.now(),
      );
      _updateStream();
    }
  }
  
  @override
  Future<void> acceptInvite(String inviteId, String userId) async {
    await _simulateNetworkDelay(null);
    final invite = _invites[inviteId];
    if (invite == null) return;
    
    final updatedInvite = ShoppingListInviteModel(
      id: invite.id,
      listId: invite.listId,
      invitedEmail: invite.invitedEmail,
      invitedByUserId: invite.invitedByUserId,
      status: InviteStatus.accepted,
      token: invite.token,
      createdAt: invite.createdAt,
      updatedAt: DateTime.now(),
    );
    _invites[inviteId] = updatedInvite;
    
    // Добавляем пользователя в список участников
    final list = _lists[invite.listId];
    if (list != null) {
      final updatedMembers = [...list.memberIds, userId];
      final updatedInvites = list.pendingInvites.map((i) {
        return i.id == inviteId ? updatedInvite : i;
      }).toList();
      
      _lists[invite.listId] = list.copyWith(
        memberIds: updatedMembers,
        pendingInvites: updatedInvites,
        updatedAt: DateTime.now(),
      );
      _updateStream();
    }
  }
  
  @override
  Future<void> rejectInvite(String inviteId) async {
    await _simulateNetworkDelay(null);
    final invite = _invites[inviteId];
    if (invite == null) return;
    
    final updatedInvite = ShoppingListInviteModel(
      id: invite.id,
      listId: invite.listId,
      invitedEmail: invite.invitedEmail,
      invitedByUserId: invite.invitedByUserId,
      status: InviteStatus.rejected,
      token: invite.token,
      createdAt: invite.createdAt,
      updatedAt: DateTime.now(),
    );
    _invites[inviteId] = updatedInvite;
    
    // Обновляем статус приглашения в списке
    final list = _lists[invite.listId];
    if (list != null) {
      final updatedInvites = list.pendingInvites.map((i) {
        return i.id == inviteId ? updatedInvite : i;
      }).toList();
      
      _lists[invite.listId] = list.copyWith(
        pendingInvites: updatedInvites,
        updatedAt: DateTime.now(),
      );
      _updateStream();
    }
  }
  
  @override
  Future<void> updateMemberPermission(String listId, String userId, String permission) async {
    await _simulateNetworkDelay(null);
    // В реальной реализации здесь будет обновление разрешений
    // Для Mock просто обновляем список
    final list = _lists[listId];
    if (list != null) {
      _lists[listId] = list.copyWith(updatedAt: DateTime.now());
      _updateStream();
    }
  }
  
  void _updateStream() {
    _listsSubject.add(_lists.values.toList());
  }
  
  void dispose() {
    _listsSubject.close();
  }
}

