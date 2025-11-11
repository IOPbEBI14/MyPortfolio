import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/providers/repository_providers.dart';

// Контроллер аутентификации с использованием AsyncNotifier
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Начальное состояние
    return null;
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final auth = ref.read(firebaseAuthProvider);
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final auth = ref.read(firebaseAuthProvider);
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      final auth = ref.read(firebaseAuthProvider);
      await auth.signOut();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Провайдер для контроллера
final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});