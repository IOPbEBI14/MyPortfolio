import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Правильные импорты
import 'package:smart_todo/core/providers/auth_providers.dart';
import '../../../../domain/entities/task.dart';
import '../../../auth/application/auth_controller.dart';
import '../../application/simple_task_controller.dart'; // Используем простой контроллер
import '../widgets/edit_task_form.dart'; // Добавляем импорт
import '../widgets/task_filter_chip.dart'; // Добавляем импорт
import '../../application/simple_filter.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasks = ref.watch(simpleTaskControllerProvider);
    final currentFilter = ref.watch(taskFilterProvider); // Из simple_filter.dart

    // Фильтруем задачи с помощью функции из simple_filter.dart
    final tasks = filterTasks(allTasks, currentFilter);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          if (currentFilter == TaskFilter.completed)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                _showClearCompletedDialog(context, ref);
              },
              tooltip: 'Clear completed tasks',
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context, ref);
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TaskFilterChip(),
          ),
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildBody(tasks, ref, context, currentFilter, allTasks),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Остальные методы остаются без изменений...
  Widget _buildBody(List<Task> tasks, WidgetRef ref, BuildContext context, TaskFilter currentFilter, List<Task> allTasks) {
    if (tasks.isEmpty) {
      return _buildEmptyState(currentFilter, allTasks);
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskTile(task, ref, context);
      },
    );
  }

  Widget _buildEmptyState(TaskFilter currentFilter, List<Task> allTasks) {
    String message;
    String subtitle;

    if (allTasks.isEmpty) {
      message = 'No tasks yet';
      subtitle = 'Tap + to add your first task';
    } else {
      switch (currentFilter) {
        case TaskFilter.active:
          message = 'No active tasks';
          subtitle = 'All tasks are completed! 🎉';
          break;
        case TaskFilter.completed:
          message = 'No completed tasks';
          subtitle = 'Time to get things done! 💪';
          break;
        case TaskFilter.all:
          message = 'No tasks';
          subtitle = 'Something went wrong';
          break;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ... остальные методы без изменений
  Widget _buildTaskTile(Task task, WidgetRef ref, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            ref.read(simpleTaskControllerProvider.notifier).toggleTaskCompletion(task.id);
          },
        ),
        title: Text(
          task.title,
          style: task.isCompleted
              ? TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          )
              : TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.blue[800],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  task.description!,
                  style: TextStyle(
                    color: task.isCompleted ? Colors.grey : Colors.grey[700],
                    fontSize: 14,
                    fontStyle: task.isCompleted ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
            if (task.tags.isNotEmpty)
              Wrap(
                spacing: 4,
                children: task.tags.map((tag) => Chip(
                  label: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 10,
                      color: task.isCompleted ? Colors.grey : null,
                    ),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: task.isCompleted ? Colors.grey[200] : null,
                )).toList(),
              ),
          ],
        ),
        trailing: _buildPriorityIndicator(task.priority),
        onLongPress: () {
          _showDeleteDialog(context, ref, task);
        },
        onTap: () {
          _showEditTaskDialog(context, ref, task);
        },
      ),
    );
  }

  Widget _buildPriorityIndicator(TaskPriority priority) {
    final (color, label) = switch (priority) {
      TaskPriority.low => (Colors.green, 'Low'),
      TaskPriority.medium => (Colors.orange, 'Medium'),
      TaskPriority.high => (Colors.red, 'High'),
      TaskPriority.urgent => (Colors.purple, 'Urgent'),
    };

    return Tooltip(
      message: '$label Priority',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCompletedDialog(BuildContext context, WidgetRef ref) {
    final completedTasks = ref.read(simpleTaskControllerProvider)
        .where((task) => task.isCompleted)
        .toList();

    if (completedTasks.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed Tasks'),
        content: Text('Are you sure you want to delete ${completedTasks.length} completed task${completedTasks.length > 1 ? 's' : ''}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              for (final task in completedTasks) {
                ref.read(simpleTaskControllerProvider.notifier).deleteTask(task.id);
              }
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cleared ${completedTasks.length} completed task${completedTasks.length > 1 ? 's' : ''}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: EditTaskForm(
          task: task,
          onSave: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(simpleTaskControllerProvider.notifier).deleteTask(task.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted: ${task.title}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authControllerProvider.notifier).signOut();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: AddTaskForm(onAddTask: () {
          Navigator.of(context).pop();
        }),
      ),
    );
  }
}

// AddTaskForm остается без изменений
class AddTaskForm extends ConsumerStatefulWidget {
  final VoidCallback onAddTask;

  const AddTaskForm({super.key, required this.onAddTask});

  @override
  ConsumerState<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends ConsumerState<AddTaskForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task Title *',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<TaskPriority>(
            value: _selectedPriority,
            items: TaskPriority.values.map((priority) {
              return DropdownMenuItem(
                value: priority,
                child: Text(
                  priority.name.toUpperCase(),
                  style: TextStyle(
                    color: _getPriorityColor(priority),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPriority = value!;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Priority',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _titleController.text.trim().isEmpty
                      ? null
                      : _addTask,
                  child: const Text('Add Task'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.low => Colors.green,
      TaskPriority.medium => Colors.orange,
      TaskPriority.high => Colors.red,
      TaskPriority.urgent => Colors.purple,
    };
  }

  void _addTask() {
    if (_titleController.text.trim().isEmpty) return;

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      priority: _selectedPriority,
      deadline: null,
      tags: [],
      isCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: 'demo-user',
    );

    ref.read(simpleTaskControllerProvider.notifier).addTask(newTask);
    widget.onAddTask();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task added successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}