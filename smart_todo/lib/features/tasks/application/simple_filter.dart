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

// Провайдер для фильтрации по тегам
final selectedTagsProvider = NotifierProvider<SelectedTagsNotifier, List<String>>(() {
  return SelectedTagsNotifier();
});

class SelectedTagsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return [];
  }

  void toggleTag(String tag) {
    if (state.contains(tag)) {
      state = state.where((t) => t != tag).toList();
    } else {
      state = [...state, tag];
    }
  }

  void clearTags() {
    state = [];
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

// Функция для фильтрации задач по тегам
List<Task> filterByTags(List<Task> tasks, List<String> selectedTags) {
  if (selectedTags.isEmpty) return tasks;
  
  return tasks.where((task) {
    // Задача должна содержать хотя бы один из выбранных тегов
    return selectedTags.any((selectedTag) => task.tags.contains(selectedTag));
  }).toList();
}

// Провайдер для получения всех уникальных тегов
final allTagsProvider = Provider<List<String>>((ref) {
  final allTasks = ref.watch(taskControllerProvider);
  final allTags = <String>{};
  
  for (final task in allTasks) {
    allTags.addAll(task.tags);
  }
  
  return allTags.toList()..sort();
});

// Комбинированный провайдер для фильтрации, поиска и сортировки
final processedTasksProvider = Provider<List<Task>>((ref) {
  final allTasks = ref.watch(taskControllerProvider);
  final filter = ref.watch(taskFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final sortConfig = ref.watch(taskSortProvider);
  final selectedTags = ref.watch(selectedTagsProvider);

  // 1. Фильтрация по статусу
  var tasks = filterTasks(allTasks, filter);

  // 2. Фильтрация по тегам
  tasks = filterByTags(tasks, selectedTags);

  // 3. Поиск
  tasks = searchTasks(tasks, searchQuery);

  // 4. Сортировка
  tasks = sortTasks(tasks, sortConfig);

  return tasks;
});