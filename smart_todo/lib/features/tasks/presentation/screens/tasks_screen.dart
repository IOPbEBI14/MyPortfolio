import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Правильные импорты
import 'package:smart_todo/core/providers/auth_providers.dart';
import '../../../../domain/entities/task.dart';
import '../../../auth/application/auth_controller.dart';
import 'package:smart_todo/features/tasks/application/task_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/task.dart';
import '../../../auth/application/auth_controller.dart';

// Временный провайдер для демонстрации
final demoTasksProvider = Provider<List<Task>>((ref) {
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
      userId: 'demo-user',
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
      userId: 'demo-user',
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
      userId: 'demo-user',
    ),
  ];
});

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(demoTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context, ref);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                // Временная заглушка - просто показываем SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Toggled: ${task.title}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            title: Text(
              task.title,
              style: task.isCompleted
                  ? TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    )
                  : null,
            ),
            subtitle: task.description != null ? Text(task.description!) : null,
            trailing: _buildPriorityIndicator(task.priority),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPriorityIndicator(TaskPriority priority) {
    final color = switch (priority) {
      TaskPriority.low => Colors.green,
      TaskPriority.medium => Colors.orange,
      TaskPriority.high => Colors.red,
      TaskPriority.urgent => Colors.purple,
    };

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
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

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: const Text('This feature will be implemented soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}