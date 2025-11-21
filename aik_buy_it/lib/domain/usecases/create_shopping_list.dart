import '../entities/shopping_list.dart';
import '../repositories/shopping_repository.dart';

class CreateShoppingList {
  final ShoppingRepository repository;
  
  CreateShoppingList(this.repository);
  
  Future<ShoppingList> call(String name, String? description, String ownerId) {
    return repository.createList(name, description, ownerId);
  }
}

