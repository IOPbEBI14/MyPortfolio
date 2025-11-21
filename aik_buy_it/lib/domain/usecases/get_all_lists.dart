import '../entities/shopping_list.dart';
import '../repositories/shopping_repository.dart';

class GetAllLists {
  final ShoppingRepository repository;
  
  GetAllLists(this.repository);
  
  Future<List<ShoppingList>> call() {
    return repository.getAllLists();
  }
}

