import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart' as model;

// Helper функция для конвертации TaskPriority из domain в model
model.TaskPriority _convertPriority(TaskPriority priority) {
  return model.TaskPriority.values.firstWhere(
    (e) => e.name == priority.name,
    orElse: () => model.TaskPriority.medium,
  );
}

// Helper функция для конвертации TaskPriority из model в domain
TaskPriority _convertPriorityFromModel(model.TaskPriority priority) {
  return TaskPriority.values.firstWhere(
    (e) => e.name == priority.name,
    orElse: () => TaskPriority.medium,
  );
}

class LocalTaskRepository implements TaskRepository {
  final Box<model.TaskModel> _tasksBox;

  LocalTaskRepository(this._tasksBox);

  // Конвертация TaskModel в Task
  Task _modelToTask(model.TaskModel taskModel) {
    return Task(
      id: taskModel.id,
      title: taskModel.title,
      description: taskModel.description,
      priority: _convertPriorityFromModel(taskModel.priority),
      deadline: taskModel.deadline,
      tags: taskModel.tags,
      isCompleted: taskModel.isCompleted,
      createdAt: taskModel.createdAt,
      updatedAt: taskModel.updatedAt,
      userId: taskModel.userId,
    );
  }

  @override
  Stream<List<Task>> getTasks(String userId) {
    return _tasksBox.watch().map((_) {
      final userTasks = _tasksBox.values
          .where((task) => task.userId == userId)
          .toList();
      return userTasks.map((taskModel) => _modelToTask(taskModel)).toList();
    });
  }

  @override
  Future<Task?> getTaskById(String taskId) async {
    final taskModel = _tasksBox.get(taskId);
    return taskModel != null ? _modelToTask(taskModel) : null;
  }

  @override
  Future<void> createTask(Task task) async {
    final taskModel = model.TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      priority: _convertPriority(task.priority),
      deadline: task.deadline,
      tags: task.tags,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      userId: task.userId,
    );
    await _tasksBox.put(task.id, taskModel);
  }

  @override
  Future<void> updateTask(Task task) async {
    final taskModel = model.TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      priority: _convertPriority(task.priority),
      deadline: task.deadline,
      tags: task.tags,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      userId: task.userId,
    );
    await _tasksBox.put(task.id, taskModel);
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

      return userTasks.map((taskModel) => _modelToTask(taskModel)).toList();
    });
  }

  @override
  Future<void> syncTasks(String userId) async {
    // Локальная синхронизация - просто возвращаем успех
    // Реальная синхронизация будет в композитном репозитории
    await Future.delayed(const Duration(milliseconds: 100));
  }
}