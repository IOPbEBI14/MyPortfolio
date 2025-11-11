import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../data/repositories/sync_task_repository.dart';

// Провайдер для проверки соединения
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (result) => result != ConnectivityResult.none,
    loading: () => true, // Предполагаем что онлайн при загрузке
    error: (_, __) => false,
  );
});

// Основной провайдер репозитория с синхронизацией
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final localRepo = ref.watch(localTaskRepositoryProvider);
  final remoteRepo = ref.watch(firebaseTaskRepositoryProvider);
  final isOnline = ref.watch(isOnlineProvider);

  return SyncTaskRepository(
    local: localRepo,
    remote: remoteRepo,
    isOnline: isOnline,
  );
});