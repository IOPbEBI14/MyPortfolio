import '../repositories/shopping_repository.dart';

class SendInvite {
  final ShoppingRepository repository;
  
  SendInvite(this.repository);
  
  Future<void> call(String listId, String email, String invitedByUserId) {
    return repository.sendInvite(listId, email, invitedByUserId);
  }
}

