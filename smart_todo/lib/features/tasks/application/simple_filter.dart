import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/task.dart';

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