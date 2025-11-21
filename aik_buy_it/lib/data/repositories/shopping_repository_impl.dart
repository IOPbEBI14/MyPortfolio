import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../domain/entities/shopping_list.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/entities/list_permission.dart';
import '../../domain/repositories/shopping_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../datasources/remote/remote_data_source.dart';
import '../models/shopping_list_model.dart';
import '../models/shopping_item_model.dart';
import '../../core/network/network_info.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final _uuid = const Uuid();
  
  ShoppingRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<List<ShoppingList>> getAllLists() async {
    // Сначала пытаемся получить из локального хранилища
    final localLists = await localDataSource.getAllLists();
    
    // Если есть интернет, синхронизируем с удаленным хранилищем
    if (await networkInfo.isConnected) {
      try {
        await syncWithRemote();
        // После синхронизации получаем обновленные данные
        final syncedLists = await localDataSource.getAllLists();
        return syncedLists.map((model) => _toEntity(model)).toList();
      } catch (e) {
        // Если синхронизация не удалась, возвращаем локальные данные
        return localLists.map((model) => _toEntity(model)).toList();
      }
    }
    
    return localLists.map((model) => _toEntity(model)).toList();
  }
  
  @override
  Stream<List<ShoppingList>> watchAllLists() {
    // Объединяем локальный и удаленный потоки
    return Stream.periodic(const Duration(seconds: 2), (_) async {
      if (await networkInfo.isConnected) {
        try {
          await syncWithRemote();
        } catch (e) {
          // Игнорируем ошибки синхронизации
        }
      }
      final lists = await localDataSource.getAllLists();
      return lists.map((model) => _toEntity(model)).toList();
    }).asyncMap((future) => future);
  }
  
  @override
  Stream<ShoppingList?> watchListById(String id) {
    return Stream.periodic(const Duration(seconds: 1), (_) async {
      if (await networkInfo.isConnected) {
        try {
          await syncWithRemote();
        } catch (e) {
          // Игнорируем ошибки синхронизации
        }
      }
      final model = await localDataSource.getListById(id);
      return model != null ? _toEntity(model) : null;
    }).asyncMap((future) => future);
  }
  
  @override
  Future<ShoppingList?> getListById(String id) async {
    final model = await localDataSource.getListById(id);
    
    // Если есть интернет, синхронизируем
    if (await networkInfo.isConnected) {
      try {
        final remoteModel = await remoteDataSource.getListById(id);
        if (remoteModel != null) {
          // Сохраняем удаленные данные локально
          await localDataSource.saveList(remoteModel);
          return _toEntity(remoteModel);
        }
      } catch (e) {
        // Игнорируем ошибки
      }
    }
    
    return model != null ? _toEntity(model) : null;
  }
  
  @override
  Future<ShoppingList> createList(String name, String? description, String ownerId) async {
    final now = DateTime.now();
    final model = ShoppingListModel(
      id: _uuid.v4(),
      name: name,
      description: description,
      ownerId: ownerId,
      createdAt: now,
      updatedAt: now,
    );
    
    // Сохраняем локально
    await localDataSource.saveList(model);
    
    // Если есть интернет, сохраняем удаленно
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.saveList(model);
      } catch (e) {
        // Ошибка не критична, данные сохранены локально
      }
    }
    
    return _toEntity(model);
  }
  
  @override
  Future<ShoppingList> updateList(ShoppingList list) async {
    final model = _toModel(list);
    final updated = model.copyWith(updatedAt: DateTime.now());
    
    // Сохраняем локально
    await localDataSource.saveList(updated);
    
    // Если есть интернет, сохраняем удаленно
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.saveList(updated);
      } catch (e) {
        // Ошибка не критична
      }
    }
    
    return _toEntity(updated);
  }
  
  @override
  Future<void> deleteList(String id) async {
    await localDataSource.deleteList(id);
    
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteList(id);
      } catch (e) {
        // Ошибка не критична
      }
    }
  }
  
  @override
  Future<ShoppingItem> addItem(String listId, ShoppingItem item) async {
    final list = await localDataSource.getListById(listId);
    if (list == null) {
      throw Exception('List not found');
    }
    
    final itemModel = _itemToModel(item);
    final updatedItems = [...list.items, itemModel];
    final updatedList = list.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
    
    await localDataSource.saveList(updatedList);
    
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.saveList(updatedList);
      } catch (e) {
        // Ошибка не критична
      }
    }
    
    return item;
  }
  
  @override
  Future<ShoppingItem> updateItem(String listId, ShoppingItem item) async {
    final list = await localDataSource.getListById(listId);
    if (list == null) {
      throw Exception('List not found');
    }
    
    final updatedItems = list.items.map((i) {
      return i.id == item.id ? _itemToModel(item) : i;
    }).toList();
    
    final updatedList = list.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
    
    await localDataSource.saveList(updatedList);
    
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.saveList(updatedList);
      } catch (e) {
        // Ошибка не критична
      }
    }
    
    return item;
  }
  
  @override
  Future<void> deleteItem(String listId, String itemId) async {
    final list = await localDataSource.getListById(listId);
    if (list == null) {
      throw Exception('List not found');
    }
    
    final updatedItems = list.items.where((i) => i.id != itemId).toList();
    final updatedList = list.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
    
    await localDataSource.saveList(updatedList);
    
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.saveList(updatedList);
      } catch (e) {
        // Ошибка не критична
      }
    }
  }
  
  @override
  Future<void> toggleItemCompletion(String listId, String itemId) async {
    final list = await localDataSource.getListById(listId);
    if (list == null) {
      throw Exception('List not found');
    }
    
    final updatedItems = list.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(
          isCompleted: !item.isCompleted,
          updatedAt: DateTime.now(),
        );
      }
      return item;
    }).toList();
    
    final updatedList = list.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
    
    await localDataSource.saveList(updatedList);
    
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.saveList(updatedList);
      } catch (e) {
        // Ошибка не критична
      }
    }
  }
  
  @override
  Future<void> sendInvite(String listId, String email, String invitedByUserId) async {
    if (await networkInfo.isConnected) {
      await remoteDataSource.sendInvite(listId, email, invitedByUserId);
      // Обновляем локальные данные после отправки приглашения
      await syncWithRemote();
    } else {
      throw Exception('Нет подключения к интернету');
    }
  }
  
  @override
  Future<void> acceptInvite(String inviteId, String userId) async {
    if (await networkInfo.isConnected) {
      await remoteDataSource.acceptInvite(inviteId, userId);
      await syncWithRemote();
    } else {
      throw Exception('Нет подключения к интернету');
    }
  }
  
  @override
  Future<void> rejectInvite(String inviteId) async {
    if (await networkInfo.isConnected) {
      await remoteDataSource.rejectInvite(inviteId);
      await syncWithRemote();
    } else {
      throw Exception('Нет подключения к интернету');
    }
  }
  
  @override
  Future<ListPermission> getUserPermission(String listId, String userId) async {
    final list = await localDataSource.getListById(listId);
    if (list == null) {
      return ListPermission.viewer;
    }
    
    if (list.ownerId == userId) {
      return ListPermission.owner;
    }
    
    if (list.memberIds.contains(userId)) {
      // По умолчанию участники имеют права редактора
      // В реальной реализации здесь будет проверка разрешений из БД
      return ListPermission.editor;
    }
    
    return ListPermission.viewer;
  }
  
  @override
  Future<void> updateMemberPermission(String listId, String userId, ListPermission permission) async {
    if (await networkInfo.isConnected) {
      await remoteDataSource.updateMemberPermission(
        listId,
        userId,
        permission.name,
      );
      await syncWithRemote();
    } else {
      throw Exception('Нет подключения к интернету');
    }
  }
  
  @override
  Future<void> syncWithRemote() async {
    if (!await networkInfo.isConnected) {
      return;
    }
    
    try {
      // Получаем удаленные списки
      final remoteLists = await remoteDataSource.getAllLists();
      
      // Получаем локальные списки
      final localLists = await localDataSource.getAllLists();
      final localMap = {for (var list in localLists) list.id: list};
      
      // Синхронизируем: обновляем локальные данные удаленными
      for (var remoteList in remoteLists) {
        final localList = localMap[remoteList.id];
        
        if (localList == null || remoteList.updatedAt.isAfter(localList.updatedAt)) {
          // Удаленная версия новее или локальной нет
          await localDataSource.saveList(remoteList);
        } else if (localList.updatedAt.isAfter(remoteList.updatedAt)) {
          // Локальная версия новее - отправляем на сервер
          await remoteDataSource.saveList(localList);
        }
      }
      
      // Добавляем новые удаленные списки, которых нет локально
      for (var remoteList in remoteLists) {
        if (!localMap.containsKey(remoteList.id)) {
          await localDataSource.saveList(remoteList);
        }
      }
    } catch (e) {
      // Игнорируем ошибки синхронизации
    }
  }
  
  ShoppingList _toEntity(ShoppingListModel model) {
    return ShoppingList(
      id: model.id,
      name: model.name,
      description: model.description,
      ownerId: model.ownerId,
      memberIds: model.memberIds,
      items: model.items.map((item) => ShoppingItem(
        id: item.id,
        name: item.name,
        quantity: item.quantity,
        category: item.category,
        isCompleted: item.isCompleted,
        notes: item.notes,
        addedByUserId: item.addedByUserId,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      )).toList(),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
  
  ShoppingListModel _toModel(ShoppingList entity) {
    return ShoppingListModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      ownerId: entity.ownerId,
      memberIds: entity.memberIds,
      items: entity.items.map((item) => _itemToModel(item)).toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
  
  ShoppingItemModel _itemToModel(ShoppingItem item) {
    return ShoppingItemModel(
      id: item.id,
      name: item.name,
      quantity: item.quantity,
      category: item.category,
      isCompleted: item.isCompleted,
      notes: item.notes,
      addedByUserId: item.addedByUserId,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }
}

