import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/shopping_list.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/usecases/get_all_lists.dart';
import '../../domain/usecases/create_shopping_list.dart';
import '../../domain/usecases/add_item_to_list.dart';
import '../../domain/usecases/toggle_item_completion.dart';
import '../../domain/usecases/delete_item.dart';
import '../../domain/usecases/delete_list.dart';
import '../../domain/usecases/send_invite.dart';
import '../../domain/repositories/shopping_repository.dart';

part 'shopping_list_state.dart';

class ShoppingListCubit extends Cubit<ShoppingListState> {
  final GetAllLists getAllLists;
  final CreateShoppingList createShoppingList;
  final AddItemToList addItemToList;
  final ToggleItemCompletion toggleItemCompletion;
  final DeleteItem deleteItem;
  final DeleteList deleteList;
  final SendInvite sendInvite;
  final ShoppingRepository repository;
  StreamSubscription<List<ShoppingList>>? _listsSubscription;
  
  ShoppingListCubit({
    required this.getAllLists,
    required this.createShoppingList,
    required this.addItemToList,
    required this.toggleItemCompletion,
    required this.deleteItem,
    required this.deleteList,
    required this.sendInvite,
    required this.repository,
  }) : super(ShoppingListInitial());
  
  void watchLists() {
    emit(ShoppingListLoading());
    
    // Отменяем предыдущую подписку
    _listsSubscription?.cancel();
    
    // Подписываемся на поток обновлений
    _listsSubscription = repository.watchAllLists().listen(
      (lists) {
        emit(ShoppingListLoaded(lists: lists));
      },
      onError: (error) {
        emit(ShoppingListError(message: error.toString()));
      },
    );
  }
  
  Future<void> loadLists() async {
    emit(ShoppingListLoading());
    try {
      final lists = await getAllLists();
      emit(ShoppingListLoaded(lists: lists));
    } catch (e) {
      emit(ShoppingListError(message: e.toString()));
    }
  }
  
  Future<void> createList(String name, String? description, String ownerId) async {
    try {
      final newList = await createShoppingList(name, description, ownerId);
      final currentState = state;
      if (currentState is ShoppingListLoaded) {
        emit(ShoppingListLoaded(lists: [...currentState.lists, newList]));
      } else {
        await loadLists();
      }
    } catch (e) {
      emit(ShoppingListError(message: e.toString()));
    }
  }
  
  Future<void> addItem(String listId, ShoppingItem item) async {
    try {
      await addItemToList(listId, item);
      await loadLists();
    } catch (e) {
      emit(ShoppingListError(message: e.toString()));
    }
  }
  
  Future<void> toggleItem(String listId, String itemId) async {
    try {
      await toggleItemCompletion(listId, itemId);
      await loadLists();
    } catch (e) {
      emit(ShoppingListError(message: e.toString()));
    }
  }
  
  Future<void> removeItem(String listId, String itemId) async {
    try {
      await deleteItem(listId, itemId);
      await loadLists();
    } catch (e) {
      emit(ShoppingListError(message: e.toString()));
    }
  }
  
  Future<void> removeList(String id) async {
    try {
      await deleteList(id);
      // Не нужно вызывать loadLists, так как Stream автоматически обновит состояние
    } catch (e) {
      emit(ShoppingListError(message: e.toString()));
    }
  }
  
  Future<void> inviteUser(String listId, String email, String userId) async {
    try {
      await sendInvite(listId, email, userId);
      // Stream автоматически обновит состояние
    } catch (e) {
      emit(ShoppingListError(message: e.toString()));
    }
  }
  
  @override
  Future<void> close() {
    _listsSubscription?.cancel();
    return super.close();
  }
}

