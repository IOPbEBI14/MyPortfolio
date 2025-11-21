import '../repositories/shopping_repository.dart';

class AcceptInvite {
  final ShoppingRepository repository;
  
  AcceptInvite(this.repository);
  
  Future<void> call(String inviteId, String userId) {
    return repository.acceptInvite(inviteId, userId);
  }
}

