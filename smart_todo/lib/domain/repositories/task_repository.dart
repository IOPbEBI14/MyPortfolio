import '../entities/task.dart';

abstract class TaskRepository {
  // Получить все задачи пользователя
  Stream<List<Task>> getTasks(String userId);
  
  // Получить задачу по ID
  Future<Task?> getTaskById(String taskId);
  
  // Создать новую задачу
  Future<void> createTask(Task task);
  
  // Обновить задачу
  Future<void> updateTask(Task task);
  
  // Удалить задачу
  Future<void> deleteTask(String taskId);
  
  // Получить задачи по фильтру
  Stream<List<Task>> getTasksByFilter({
    required String userId,
    bool? isCompleted,
    String? priority,
    List<String>? tags,
  });
  
  // Синхронизировать локальные данные с Firebase
  Future<void> syncTasks(String userId);
}