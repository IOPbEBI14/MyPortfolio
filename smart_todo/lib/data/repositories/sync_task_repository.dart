import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

class SyncTaskRepository implements TaskRepository {
  final TaskRepository local;
  final TaskRepository remote;
  final bool isOnline;

  SyncTaskRepository({
    required this.local,
    required this.remote,
    required this.isOnline,
  });

  @override
  Stream<List<Task>> getTasks(String userId) {
    // Всегда показываем локальные данные для мгновенного отклика
    return local.getTasks(userId);
  }

  @override
  Future<Task?> getTaskById(String taskId) async {
    return await local.getTaskById(taskId);
  }

  @override
  Future<void> createTask(Task task) async {
    // Сначала сохраняем локально
    await local.createTask(task);
    
    // Затем синхронизируем с Firebase если онлайн
    if (isOnline) {
      try {
        await remote.createTask(task);
        // Обновляем статус синхронизации если нужно
      } catch (e) {
        // Задача останется в локальной БД для последующей синхронизации
        print('Failed to sync task to Firebase: $e');
      }
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    // Обновляем локально
    await local.updateTask(task);
    
    // Синхронизируем если онлайн
    if (isOnline) {
      try {
        await remote.updateTask(task);
      } catch (e) {
        print('Failed to sync task update to Firebase: $e');
      }
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    // Удаляем локально
    await local.deleteTask(taskId);
    
    // Синхронизируем если онлайн
    if (isOnline) {
      try {
        await remote.deleteTask(taskId);
      } catch (e) {
        print('Failed to sync task deletion to Firebase: $e');
      }
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
    if (!isOnline) return;

    try {
      // Получаем задачи из Firebase
      final remoteTasks = await remote.getTasks(userId).first;
      
      // Сохраняем их локально
      for (final task in remoteTasks) {
        await local.createTask(task);
      }
      
      print('Successfully synced ${remoteTasks.length} tasks from Firebase');
    } catch (e) {
      print('Failed to sync tasks: $e');
    }
  }
}