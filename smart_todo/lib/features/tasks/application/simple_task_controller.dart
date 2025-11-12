import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/task.dart';

// Для Riverpod 3.0 используем NotifierProvider вместо StateNotifierProvider
final simpleTaskControllerProvider = NotifierProvider<SimpleTaskController, List<Task>>(() {
  return SimpleTaskController();
});

class SimpleTaskController extends Notifier<List<Task>> {
  @override
  List<Task> build() {
    return _getInitialTasks();
  }

  List<Task> _getInitialTasks() {
    return [
      Task(
        id: '1',
        title: 'Learn Flutter',
        description: 'Study Riverpod and Firebase',
        priority: TaskPriority.high,
        deadline: DateTime.now().add(const Duration(days: 1)),
        tags: ['study', 'programming'],
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: 'demo-user',
      ),
      Task(
        id: '2',
        title: 'Buy groceries',
        description: 'Milk, Eggs, Bread',
        priority: TaskPriority.medium,
        deadline: DateTime.now().add(const Duration(days: 2)),
        tags: ['shopping'],
        isCompleted: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: 'demo-user',
      ),
      Task(
        id: '3',
        title: 'Finish portfolio app',
        description: 'Complete Smart Todo project',
        priority: TaskPriority.urgent,
        deadline: DateTime.now().add(const Duration(days: 7)),
        tags: ['work', 'portfolio'],
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: 'demo-user',
      ),
    ];
  }

  void addTask(Task task) {
    state = [...state, task];
  }

  void toggleTaskCompletion(String taskId) {
    state = state.map((task) {
      if (task.id == taskId) {
        return task.copyWith(
          isCompleted: !task.isCompleted,
          updatedAt: DateTime.now(),
        );
      }
      return task;
    }).toList();
  }

  void deleteTask(String taskId) {
    state = state.where((task) => task.id != taskId).toList();
  }

  void updateTask(Task updatedTask) {
    state = state.map((task) {
      if (task.id == updatedTask.id) {
        return updatedTask.copyWith(updatedAt: DateTime.now());
      }
      return task;
    }).toList();
  }
}