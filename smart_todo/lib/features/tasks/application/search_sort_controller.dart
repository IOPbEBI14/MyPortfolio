import 'package:flutter/material.dart'; // Добавляем этот импорт
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/task.dart';

// Типы сортировки
enum TaskSort {
  createdAt('Newest First', Icons.access_time, 'Oldest First'),
  priority('Priority High → Low', Icons.flag, 'Priority Low → High'),
  title('Title A → Z', Icons.sort_by_alpha, 'Title Z → A'),
  deadline('Deadline Soonest', Icons.calendar_today, 'Deadline Latest');

  const TaskSort(this.label, this.icon, this.reverseLabel);
  final String label;
  final IconData icon;
  final String reverseLabel;
}

// Класс для хранения сортировки и направления
class SortConfig {
  final TaskSort sort;
  final bool isReversed;

  const SortConfig({
    required this.sort,
    required this.isReversed,
  });

  SortConfig copyWith({
    TaskSort? sort,
    bool? isReversed,
  }) {
    return SortConfig(
      sort: sort ?? this.sort,
      isReversed: isReversed ?? this.isReversed,
    );
  }

  String get displayLabel {
    return isReversed ? sort.reverseLabel : sort.label;
  }
}

// Провайдер для поискового запроса
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

// Провайдер для конфигурации сортировки
final taskSortProvider = NotifierProvider<TaskSortNotifier, SortConfig>(() {
  return TaskSortNotifier();
});

class TaskSortNotifier extends Notifier<SortConfig> {
  @override
  SortConfig build() {
    return const SortConfig(
      sort: TaskSort.createdAt,
      isReversed: false,
    );
  }

  void setSort(TaskSort sort) {
    final currentConfig = state;

    // Если нажимаем на ту же сортировку - переворачиваем направление
    if (currentConfig.sort == sort) {
      state = currentConfig.copyWith(isReversed: !currentConfig.isReversed);
    } else {
      // Если новая сортировка - сбрасываем направление
      state = SortConfig(sort: sort, isReversed: false);
    }
  }

  void toggleDirection() {
    state = state.copyWith(isReversed: !state.isReversed);
  }
}

// Функция для поиска задач
List<Task> searchTasks(List<Task> tasks, String query) {
  if (query.isEmpty) return tasks;

  final lowercaseQuery = query.toLowerCase();
  return tasks.where((task) {
    final titleMatch = task.title.toLowerCase().contains(lowercaseQuery);
    final descriptionMatch = task.description?.toLowerCase().contains(lowercaseQuery) ?? false;
    final tagsMatch = task.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));

    return titleMatch || descriptionMatch || tagsMatch;
  }).toList();
}

// Функция для сортировки задач
List<Task> sortTasks(List<Task> tasks, SortConfig sortConfig) {
  final sortedTasks = List<Task>.from(tasks);
  final isReversed = sortConfig.isReversed;

  switch (sortConfig.sort) {
    case TaskSort.createdAt:
      sortedTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case TaskSort.priority:
      sortedTasks.sort((a, b) => _getPriorityValue(b.priority).compareTo(_getPriorityValue(a.priority)));
      break;
    case TaskSort.title:
      sortedTasks.sort((a, b) => a.title.compareTo(b.title));
      break;
    case TaskSort.deadline:
      sortedTasks.sort((a, b) {
        if (a.deadline == null && b.deadline == null) return 0;
        if (a.deadline == null) return 1;
        if (b.deadline == null) return -1;
        return a.deadline!.compareTo(b.deadline!);
      });
      break;
  }

  // Применяем обратную сортировку если нужно
  if (isReversed) {
    return sortedTasks.reversed.toList();
  }

  return sortedTasks;
}

int _getPriorityValue(TaskPriority priority) {
  return switch (priority) {
    TaskPriority.low => 1,
    TaskPriority.medium => 2,
    TaskPriority.high => 3,
    TaskPriority.urgent => 4,
  };
}