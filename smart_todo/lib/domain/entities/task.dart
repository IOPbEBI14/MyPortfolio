import 'package:equatable/equatable.dart';

enum TaskPriority { low, medium, high, urgent }

class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final DateTime? deadline;
  final List<String> tags;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    this.deadline,
    required this.tags,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        priority,
        deadline,
        tags,
        isCompleted,
        createdAt,
        updatedAt,
        userId,
      ];

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? deadline,
    List<String>? tags,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      tags: tags ?? this.tags,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      userId: userId ?? this.userId,
    );
  }

  // Конвертация Task <-> TaskModel
  factory Task.fromModel(dynamic model) {
    return Task(
      id: model.id,
      title: model.title,
      description: model.description,
      priority: model.priority,
      deadline: model.deadline,
      tags: model.tags,
      isCompleted: model.isCompleted,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      userId: model.userId,
    );
  }
}