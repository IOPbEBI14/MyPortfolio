import '../entities/shopping_item.dart';
import '../repositories/shopping_repository.dart';

class AddItemToList {
  final ShoppingRepository repository;
  
  AddItemToList(this.repository);
  
  Future<ShoppingItem> call(String listId, ShoppingItem item) {
    return repository.addItem(listId, item);
  }
}

