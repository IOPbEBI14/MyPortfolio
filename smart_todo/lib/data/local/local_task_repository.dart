import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

class LocalTaskRepository implements TaskRepository {
  final Box<TaskModel> _tasksBox;

  LocalTaskRepository(this._tasksBox);

  @override
  Stream<List<Task>> getTasks(String userId) {
    return _tasksBox.watch().map((_) {
      final userTasks = _tasksBox.values
          .where((task) => task.userId == userId)
          .toList();
      return userTasks.map((model) => Task.fromModel(model)).toList();
    });
  }

  @override
  Future<Task?> getTaskById(String taskId) async {
    final model = _tasksBox.get(taskId);
    return model != null ? Task.fromModel(model) : null;
  }

  @override
  Future<void> createTask(Task task) async {
    final model = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      priority: task.priority,
      deadline: task.deadline,
      tags: task.tags,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      userId: task.userId,
    );
    await _tasksBox.put(task.id, model);
  }

  @override
  Future<void> updateTask(Task task) async {
    final model = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      priority: task.priority,
      deadline: task.deadline,
      tags: task.tags,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      userId: task.userId,
    );
    await _tasksBox.put(task.id, model);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _tasksBox.delete(taskId);
  }

  @override
  Stream<List<Task>> getTasksByFilter({
    required String userId,
    bool? isCompleted,
    String? priority,
    List<String>? tags,
  }) {
    return _tasksBox.watch().map((_) {
      var userTasks = _tasksBox.values.where((task) => task.userId == userId);

      if (isCompleted != null) {
        userTasks = userTasks.where((task) => task.isCompleted == isCompleted);
      }

      if (priority != null) {
        userTasks = userTasks.where((task) => task.priority.name == priority);
      }

      if (tags != null && tags.isNotEmpty) {
        userTasks = userTasks.where((task) =>
            task.tags.any((tag) => tags.contains(tag)));
      }

      return userTasks.map((model) => Task.fromModel(model)).toList();
    });
  }

  @override
  Future<void> syncTasks(String userId) async {
    // Локальная синхронизация - просто возвращаем успех
    // Реальная синхронизация будет в композитном репозитории
    await Future.delayed(const Duration(milliseconds: 100));
  }
}