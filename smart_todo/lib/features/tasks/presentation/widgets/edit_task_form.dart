import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/task.dart';
import '../../application/simple_task_controller.dart';

class EditTaskForm extends ConsumerStatefulWidget {
  final Task task;
  final VoidCallback onSave;

  const EditTaskForm({
    super.key,
    required this.task,
    required this.onSave,
  });

  @override
  ConsumerState<EditTaskForm> createState() => _EditTaskFormState();
}

class _EditTaskFormState extends ConsumerState<EditTaskForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskPriority _selectedPriority;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _selectedPriority = widget.task.priority;
    _isCompleted = widget.task.isCompleted;
  }

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
            maxLines: 3,
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
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Completed'),
            value: _isCompleted,
            onChanged: (value) {
              setState(() {
                _isCompleted = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
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
                      : _saveTask,
                  child: const Text('Save'),
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

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) return;

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      priority: _selectedPriority,
      isCompleted: _isCompleted,
      updatedAt: DateTime.now(),
    );

    ref.read(simpleTaskControllerProvider.notifier).updateTask(updatedTask);
    widget.onSave();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task updated successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}