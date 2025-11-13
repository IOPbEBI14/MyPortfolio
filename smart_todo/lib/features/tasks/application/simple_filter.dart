import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/task.dart';
import 'search_sort_controller.dart'; // Добавляем импорт
import 'task_controller_simple.dart'; // Используем упрощенный контроллер
import '../domain/task_types.dart'; // Добавляем импорт типов

// Провайдер для состояния фильтрации
final taskFilterProvider = NotifierProvider<TaskFilterNotifier, TaskFilter>(() {
  return TaskFilterNotifier();
});

class TaskFilterNotifier extends Notifier<TaskFilter> {
  @override
  TaskFilter build() {
    return TaskFilter.all;
  }
}

// Функция для фильтрации задач
List<Task> filterTasks(List<Task> tasks, TaskFilter filter) {
  switch (filter) {
    case TaskFilter.all:
      return tasks;
    case TaskFilter.active:
      return tasks.where((task) => !task.isCompleted).toList();
    case TaskFilter.completed:
      return tasks.where((task) => task.isCompleted).toList();
  }
}

// Комбинированный провайдер для фильтрации, поиска и сортировки
final processedTasksProvider = Provider<List<Task>>((ref) {
  final allTasks = ref.watch(taskControllerProvider);
  final filter = ref.watch(taskFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final sortConfig = ref.watch(taskSortProvider);

  // 1. Фильтрация
  var tasks = filterTasks(allTasks, filter);

  // 2. Поиск
  tasks = searchTasks(tasks, searchQuery);

  // 3. Сортировка
  tasks = sortTasks(tasks, sortConfig);

  return tasks;
});