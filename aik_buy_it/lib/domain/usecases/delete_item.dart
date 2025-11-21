import '../repositories/shopping_repository.dart';

class DeleteItem {
  final ShoppingRepository repository;
  
  DeleteItem(this.repository);
  
  Future<void> call(String listId, String itemId) {
    return repository.deleteItem(listId, itemId);
  }
}

