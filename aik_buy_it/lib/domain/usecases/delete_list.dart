import '../repositories/shopping_repository.dart';

class DeleteList {
  final ShoppingRepository repository;
  
  DeleteList(this.repository);
  
  Future<void> call(String id) {
    return repository.deleteList(id);
  }
}

