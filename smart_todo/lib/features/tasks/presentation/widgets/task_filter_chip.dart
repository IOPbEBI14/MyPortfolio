import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/task.dart'; // Добавляем импорт
import '../../application/simple_task_controller.dart'; // Добавляем импорт
import '../../application/simple_filter.dart';

class TaskFilterChip extends ConsumerWidget {
  const TaskFilterChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(taskFilterProvider); // Из simple_filter.dart
    final tasks = ref.watch(simpleTaskControllerProvider);

    // Подсчет задач по статусам
    final activeCount = tasks.where((task) => !task.isCompleted).length;
    final completedCount = tasks.where((task) => task.isCompleted).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            context: context,
            ref: ref,
            filter: TaskFilter.all,
            currentFilter: currentFilter,
            label: 'All (${tasks.length})',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            ref: ref,
            filter: TaskFilter.active,
            currentFilter: currentFilter,
            label: 'Active ($activeCount)',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            ref: ref,
            filter: TaskFilter.completed,
            currentFilter: currentFilter,
            label: 'Completed ($completedCount)',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required WidgetRef ref,
    required TaskFilter filter,
    required TaskFilter currentFilter,
    required String label,
  }) {
    final isSelected = currentFilter == filter;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        ref.read(taskFilterProvider.notifier).setFilter(filter);
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Colors.white,
    );
  }
}