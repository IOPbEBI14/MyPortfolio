import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/task.dart';
import 'simple_task_controller.dart';
import 'search_sort_controller.dart'; // Добавляем импорт

// Типы фильтров
enum TaskFilter {
  all,
  active,
  completed,
}

// В Riverpod 3.0.3 используем NotifierProvider для состояния фильтра
final taskFilterProvider = NotifierProvider<TaskFilterNotifier, TaskFilter>(() {
  return TaskFilterNotifier();
});

class TaskFilterNotifier extends Notifier<TaskFilter> {
  @override
  TaskFilter build() {
    return TaskFilter.all;
  }

  void setFilter(TaskFilter filter) {
    state = filter;
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
  final allTasks = ref.watch(simpleTaskControllerProvider);
  final filter = ref.watch(taskFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final sort = ref.watch(taskSortProvider);

  // 1. Фильтрация
  var tasks = filterTasks(allTasks, filter);

  // 2. Поиск
  tasks = searchTasks(tasks, searchQuery);

  // 3. Сортировка
  tasks = sortTasks(tasks, sort);

  return tasks;
});