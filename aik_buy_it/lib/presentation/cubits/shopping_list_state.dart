part of 'shopping_list_cubit.dart';

abstract class ShoppingListState extends Equatable {
  const ShoppingListState();
  
  @override
  List<Object?> get props => [];
}

class ShoppingListInitial extends ShoppingListState {}

class ShoppingListLoading extends ShoppingListState {}

class ShoppingListLoaded extends ShoppingListState {
  final List<ShoppingList> lists;
  
  const ShoppingListLoaded({required this.lists});
  
  @override
  List<Object?> get props => [lists];
}

class ShoppingListError extends ShoppingListState {
  final String message;
  
  const ShoppingListError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

