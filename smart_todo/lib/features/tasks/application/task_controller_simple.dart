import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/repositories/task_repository.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/repository_providers.dart';

// StreamProvider для автоматической загрузки задач из Firebase в реальном времени
final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(taskRepositoryProvider);
  
  if (userId == null) {
    // Если пользователь не авторизован, возвращаем пустой список
    return Stream.value([]);
  }
  
  // Автоматически слушаем изменения задач из Firebase
  return repository.getTasks(userId);
});

// Упрощенный провайдер контроллера задач
final taskControllerProvider = NotifierProvider<TaskController, List<Task>>(() {
  return TaskController();
});

class TaskController extends Notifier<List<Task>> {
  TaskRepository get _taskRepository => ref.read(taskRepositoryProvider);

  @override
  List<Task> build() {
    // Инициализируем пустым списком
    // Оптимистичные обновления будут происходить через методы контроллера
    
    // Подписываемся на stream для автоматического обновления в фоне
    _listenToTasksStream();
    
    return [];
  }

  // Слушаем stream задач и обновляем состояние
  void _listenToTasksStream() {
    ref.listen<AsyncValue<List<Task>>>(
      tasksStreamProvider,
      (previous, next) {
        next.whenData((tasks) {
          // Обновляем состояние из Firebase только если:
          // 1. Это первая загрузка (состояние пустое)
          // 2. Количество задач изменилось
          // 3. Задачи из Firebase новее локальных
          if (_shouldUpdateFromFirebase(tasks)) {
            state = tasks;
          }
        });
      },
    );
  }

  // Проверяем, нужно ли обновлять состояние из Firebase
  bool _shouldUpdateFromFirebase(List<Task> firebaseTasks) {
    // Если локальное состояние пустое, загружаем данные
    if (state.isEmpty && firebaseTasks.isNotEmpty) return true;
    
    // Если количество задач изменилось, обновляем
    if (state.length != firebaseTasks.length) return true;
    
    // Проверяем, есть ли локальные задачи, которых нет в Firebase (удаленные)
    for (var localTask in state) {
      if (!firebaseTasks.any((t) => t.id == localTask.id)) {
        return true; // Задача удалена из Firebase
      }
    }
    
    // Проверяем, есть ли более новые версии задач в Firebase
    for (var firebaseTask in firebaseTasks) {
      try {
        final localTask = state.firstWhere((t) => t.id == firebaseTask.id);
        // Если задача в Firebase новее, обновляем
        if (firebaseTask.updatedAt.isAfter(localTask.updatedAt)) {
          return true;
        }
      } catch (e) {
        // Если задача не найдена локально, обновляем
        return true;
      }
    }
    
    return false;
  }

  Future<void> addTask({
    required String title,
    String? description,
    required TaskPriority priority,
    DateTime? deadline,
    List<String> tags = const [],
  }) async {
    final currentUser = ref.read(currentUserIdProvider);
    if (currentUser == null) return;

    // Используем UUID для гарантированной уникальности ID
    const uuid = Uuid();
    final newTask = Task(
      id: uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      deadline: deadline,
      tags: tags,
      isCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: currentUser,
    );

    // Оптимистичное обновление - сразу добавляем задачу в UI
    state = [newTask, ...state];

    try {
      // Сохраняем в Firebase
      await _taskRepository.createTask(newTask);
      print('✅ Task created successfully: ${newTask.title}');
    } catch (e) {
      // Если произошла ошибка, удаляем задачу из локального состояния
      state = state.where((task) => task.id != newTask.id).toList();
      print('❌ Failed to create task: $e');
      rethrow;
    }
    // Firebase stream автоматически синхронизирует данные
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final currentTasks = state;
    final task = currentTasks.firstWhere((t) => t.id == taskId);
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
    );

    // Оптимистичное обновление - сразу обновляем в UI
    state = state.map((t) => t.id == taskId ? updatedTask : t).toList();

    try {
      await _taskRepository.updateTask(updatedTask);
      print('✅ Task completion toggled: ${updatedTask.title}');
    } catch (e) {
      // Откатываем изменение при ошибке
      state = state.map((t) => t.id == taskId ? task : t).toList();
      print('❌ Failed to toggle task completion: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    // Сохраняем задачу на случай отката
    final taskToDelete = state.firstWhere((t) => t.id == taskId);
    final taskIndex = state.indexWhere((t) => t.id == taskId);

    // Оптимистичное обновление - сразу удаляем из UI
    state = state.where((task) => task.id != taskId).toList();

    try {
      await _taskRepository.deleteTask(taskId);
      print('✅ Task deleted successfully');
    } catch (e) {
      // Восстанавливаем задачу при ошибке
      final newState = List<Task>.from(state);
      newState.insert(taskIndex, taskToDelete);
      state = newState;
      print('❌ Failed to delete task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(Task updatedTask) async {
    // Сохраняем старую версию для отката
    final oldTask = state.firstWhere((t) => t.id == updatedTask.id);

    // Оптимистичное обновление - сразу обновляем в UI
    state = state.map((t) => t.id == updatedTask.id ? updatedTask : t).toList();

    try {
      await _taskRepository.updateTask(updatedTask);
      print('✅ Task updated successfully: ${updatedTask.title}');
    } catch (e) {
      // Откатываем изменение при ошибке
      state = state.map((t) => t.id == updatedTask.id ? oldTask : t).toList();
      print('❌ Failed to update task: $e');
      rethrow;
    }
  }

  Task? getTaskById(String taskId) {
    try {
      return state.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  // Метод для ручной синхронизации задач из Firebase
  Future<void> syncTasks() async {
    final currentUser = ref.read(currentUserIdProvider);
    if (currentUser == null) return;

    try {
      // Вызываем метод синхронизации из репозитория
      await _taskRepository.syncTasks(currentUser);
      
      // Инвалидируем stream провайдер для обновления данных
      ref.invalidate(tasksStreamProvider);
      
      print('✅ Manual sync completed successfully');
    } catch (e) {
      print('❌ Manual sync failed: $e');
      rethrow;
    }
  }
}

// Провайдер для статуса загрузки - используем NotifierProvider
final tasksLoadingProvider = NotifierProvider<TasksLoadingNotifier, bool>(() {
  return TasksLoadingNotifier();
});

class TasksLoadingNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void setLoading(bool loading) {
    state = loading;
  }
}