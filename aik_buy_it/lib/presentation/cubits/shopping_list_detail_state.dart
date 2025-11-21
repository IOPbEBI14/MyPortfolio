part of 'shopping_list_detail_cubit.dart';

abstract class ShoppingListDetailState extends Equatable {
  const ShoppingListDetailState();
  
  @override
  List<Object?> get props => [];
}

class ShoppingListDetailInitial extends ShoppingListDetailState {}

class ShoppingListDetailLoading extends ShoppingListDetailState {}

class ShoppingListDetailLoaded extends ShoppingListDetailState {
  final ShoppingList list;
  
  const ShoppingListDetailLoaded({required this.list});
  
  @override
  List<Object?> get props => [list];
}

class ShoppingListDetailError extends ShoppingListDetailState {
  final String message;
  
  const ShoppingListDetailError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

