import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/repository_providers.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

// Убираем прямые импорты репозиториев, используем провайдеры через ref
final syncTaskRepositoryProvider = Provider<TaskRepository>((ref) {
  final localRepo = ref.read(localTaskRepositoryProvider);
  final remoteRepo = ref.read(firebaseTaskRepositoryProvider);

  return SyncTaskRepository(
    local: localRepo,
    remote: remoteRepo,
  );
});

class SyncTaskRepository implements TaskRepository {
  final TaskRepository local;
  final TaskRepository remote;

  SyncTaskRepository({
    required this.local,
    required this.remote,
  });

  @override
  Stream<List<Task>> getTasks(String userId) {
    // Возвращаем данные из Firebase для автоматической синхронизации в реальном времени
    // Firebase автоматически обновит данные при любых изменениях
    return remote.getTasks(userId).handleError((error) {
      print('❌ Error loading tasks from Firebase: $error');
      // При ошибке возвращаем локальные данные
      return local.getTasks(userId);
    }).asyncMap((remoteTasks) async {
      // Синхронизируем полученные задачи с локальной БД
      try {
        for (final task in remoteTasks) {
          final existingTask = await local.getTaskById(task.id);
          if (existingTask != null) {
            // Обновляем существующую задачу
            if (task.updatedAt.isAfter(existingTask.updatedAt)) {
              await local.updateTask(task);
            }
          } else {
            // Создаем новую задачу
            await local.createTask(task);
          }
        }
      } catch (e) {
        print('❌ Error syncing tasks to local DB: $e');
      }
      return remoteTasks;
    });
  }

  @override
  Future<Task?> getTaskById(String taskId) async {
    return await local.getTaskById(taskId);
  }

  @override
  Future<void> createTask(Task task) async {
    // Сначала сохраняем локально для мгновенного отклика
    await local.createTask(task);

    // Затем пытаемся синхронизировать с Firebase
    try {
      await remote.createTask(task);
      print('✅ Task synced to Firebase: ${task.title}');
    } catch (e) {
      print('❌ Failed to sync task to Firebase: $e');
      // Задача останется в локальной БД для последующей синхронизации
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    // Сначала обновляем локально
    await local.updateTask(task);

    // Затем синхронизируем с Firebase
    try {
      await remote.updateTask(task);
      print('✅ Task update synced to Firebase: ${task.title}');
    } catch (e) {
      print('❌ Failed to sync task update to Firebase: $e');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    // Сначала удаляем локально
    await local.deleteTask(taskId);

    // Затем синхронизируем с Firebase
    try {
      await remote.deleteTask(taskId);
      print('✅ Task deletion synced to Firebase: $taskId');
    } catch (e) {
      print('❌ Failed to sync task deletion to Firebase: $e');
    }
  }

  @override
  Stream<List<Task>> getTasksByFilter({
    required String userId,
    bool? isCompleted,
    String? priority,
    List<String>? tags,
  }) {
    return local.getTasksByFilter(
      userId: userId,
      isCompleted: isCompleted,
      priority: priority,
      tags: tags,
    );
  }

  @override
  Future<void> syncTasks(String userId) async {
    try {
      // Получаем задачи из Firebase
      final remoteTasks = await remote.getTasks(userId).first;

      // Сохраняем их локально (используем createTask, который работает как upsert в Hive)
      for (final task in remoteTasks) {
        // Проверяем, существует ли задача локально
        final existingTask = await local.getTaskById(task.id);
        if (existingTask != null) {
          // Если существует - обновляем
          await local.updateTask(task);
        } else {
          // Если не существует - создаем
          await local.createTask(task);
        }
      }

      print('✅ Successfully synced ${remoteTasks.length} tasks from Firebase');
    } catch (e) {
      print('❌ Failed to sync tasks from Firebase: $e');
    }
  }
}