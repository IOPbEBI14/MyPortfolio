import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/task.dart';
import '../../application/task_controller_simple.dart';

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
  final _tagController = TextEditingController();
  late TaskPriority _selectedPriority;
  late bool _isCompleted;
  DateTime? _selectedDeadline;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _selectedPriority = widget.task.priority;
    _isCompleted = widget.task.isCompleted;
    _selectedDeadline = widget.task.deadline;
    _tags = List<String>.from(widget.task.tags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: SingleChildScrollView(
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
          // Deadline picker
          InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDeadline ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  _selectedDeadline = picked;
                });
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Deadline (optional)',
                border: const OutlineInputBorder(),
                suffixIcon: _selectedDeadline != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedDeadline = null;
                          });
                        },
                      )
                    : const Icon(Icons.calendar_today),
              ),
              child: Text(
                _selectedDeadline != null
                    ? '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}'
                    : 'No deadline',
                style: TextStyle(
                  color: _selectedDeadline != null ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tags input
          TextField(
            controller: _tagController,
            decoration: const InputDecoration(
              labelText: 'Tags (optional)',
              border: OutlineInputBorder(),
              hintText: 'Enter tag and press Enter',
              suffixIcon: Icon(Icons.local_offer),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty && !_tags.contains(value.trim())) {
                setState(() {
                  _tags.add(value.trim());
                  _tagController.clear(); // Очищаем поле после добавления
                });
              }
            },
          ),
          if (_tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                children: _tags.map((tag) => InputChip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    // При клике на тег - подставляем его текст для редактирования
                    setState(() {
                      _tagController.text = tag;
                      _tags.remove(tag);
                    });
                  },
                  onDeleted: () {
                    setState(() {
                      _tags.remove(tag);
                    });
                  },
                )).toList(),
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
      deadline: _selectedDeadline,
      tags: _tags,
      updatedAt: DateTime.now(),
    );

    ref.read(taskControllerProvider.notifier).updateTask(updatedTask);
    widget.onSave();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task updated successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}