import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/repositories/task_repository.dart';
import '../../../core/providers/auth_providers.dart';
    
final taskControllerProvider = AsyncNotifierProvider<TaskController, List<Task>>(() {
  return TaskController();
});

class TaskController extends AsyncNotifier<List<Task>> {
  TaskRepository get _taskRepository => ref.read(taskRepositoryProvider);

  @override
  Future<List<Task>> build() async {
    final currentUser = ref.read(currentUserIdProvider);
    if (currentUser == null) return [];

    // Временные задачи для демонстрации
    await Future.delayed(const Duration(seconds: 1));
    
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
        userId: currentUser,
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
        userId: currentUser,
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
        userId: currentUser,
      ),
    ];
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final currentUser = ref.read(currentUserIdProvider);
    if (currentUser == null) return;

    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _taskRepository.updateTask(updatedTask);
      return await build();
    });
  }

  Future<void> refreshTasks() async {
    final currentUser = ref.read(currentUserIdProvider);
    if (currentUser == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await build();
    });
  }
}