import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/shopping_list.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/repositories/shopping_repository.dart';

part 'shopping_list_detail_state.dart';

class ShoppingListDetailCubit extends Cubit<ShoppingListDetailState> {
  final ShoppingRepository repository;
  StreamSubscription<ShoppingList?>? _listSubscription;
  
  ShoppingListDetailCubit(this.repository) : super(ShoppingListDetailInitial());
  
  void watchList(String id) {
    emit(ShoppingListDetailLoading());
    
    // Отменяем предыдущую подписку
    _listSubscription?.cancel();
    
    // Подписываемся на поток обновлений
    _listSubscription = repository.watchListById(id).listen(
      (list) {
        if (list != null) {
          emit(ShoppingListDetailLoaded(list: list));
        } else {
          emit(ShoppingListDetailError(message: 'Список не найден'));
        }
      },
      onError: (error) {
        emit(ShoppingListDetailError(message: error.toString()));
      },
    );
  }
  
  Future<void> loadList(String id) async {
    emit(ShoppingListDetailLoading());
    try {
      final list = await repository.getListById(id);
      if (list != null) {
        emit(ShoppingListDetailLoaded(list: list));
      } else {
        emit(ShoppingListDetailError(message: 'Список не найден'));
      }
    } catch (e) {
      emit(ShoppingListDetailError(message: e.toString()));
    }
  }
  
  Future<void> toggleItem(String listId, String itemId) async {
    try {
      await repository.toggleItemCompletion(listId, itemId);
      // Не нужно вызывать loadList, так как Stream автоматически обновит состояние
    } catch (e) {
      emit(ShoppingListDetailError(message: e.toString()));
    }
  }
  
  Future<void> deleteItem(String listId, String itemId) async {
    try {
      await repository.deleteItem(listId, itemId);
      // Не нужно вызывать loadList, так как Stream автоматически обновит состояние
    } catch (e) {
      emit(ShoppingListDetailError(message: e.toString()));
    }
  }
  
  Future<void> sendInvite(String listId, String email, String userId) async {
    try {
      await repository.sendInvite(listId, email, userId);
    } catch (e) {
      emit(ShoppingListDetailError(message: e.toString()));
    }
  }
  
  @override
  Future<void> close() {
    _listSubscription?.cancel();
    return super.close();
  }
}

