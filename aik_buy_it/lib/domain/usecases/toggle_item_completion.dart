import '../repositories/shopping_repository.dart';

class ToggleItemCompletion {
  final ShoppingRepository repository;
  
  ToggleItemCompletion(this.repository);
  
  Future<void> call(String listId, String itemId) {
    return repository.toggleItemCompletion(listId, itemId);
  }
}

