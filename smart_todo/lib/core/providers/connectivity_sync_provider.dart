import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../features/tasks/application/task_controller_simple.dart';
import 'auth_providers.dart';

// Провайдер для отслеживания изменений подключения и автоматической синхронизации
final connectivitySyncProvider = Provider<ConnectivitySync>((ref) {
  return ConnectivitySync(ref);
});

class ConnectivitySync {
  final Ref ref;
  bool _wasOffline = false;

  ConnectivitySync(this.ref) {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    // Слушаем изменения подключения
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      final isNowOnline = result != ConnectivityResult.none;
      
      // Если было оффлайн, а теперь онлайн - синхронизируем
      if (_wasOffline && isNowOnline) {
        print('🌐 Connection restored! Starting automatic sync...');
        await _syncTasksOnReconnect();
      }
      
      _wasOffline = !isNowOnline;
      
      if (!isNowOnline) {
        print('📴 Connection lost. Working offline...');
      }
    });
  }

  Future<void> _syncTasksOnReconnect() async {
    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId != null) {
        // Даем немного времени для стабилизации подключения
        await Future.delayed(const Duration(seconds: 1));
        
        // Запускаем синхронизацию
        await ref.read(taskControllerProvider.notifier).syncTasks();
        print('✅ Automatic sync completed successfully');
      }
    } catch (e) {
      print('❌ Automatic sync failed: $e');
    }
  }
}

