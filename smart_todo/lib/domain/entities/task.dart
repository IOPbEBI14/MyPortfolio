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
      updatedAt: updatedAt ?? DateTime.now(), // Всегда обновляем при изменениях
      userId: userId ?? this.userId,
    );
  }

  // Конвертация в Map для Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'priority': priority.name,
      'deadline': deadline?.millisecondsSinceEpoch,
      'tags': tags,
      'isCompleted': isCompleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'userId': userId,
    };
  }

  // Создание из Map из Firestore
  factory Task.fromFirestore(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      title: data['title'] as String,
      description: data['description'] as String?,
      priority: TaskPriority.values.firstWhere(
            (e) => e.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      deadline: data['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['deadline'] as int)
          : null,
      tags: (data['tags'] as List<dynamic>).cast<String>(),
      isCompleted: data['isCompleted'] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] as int),
      userId: data['userId'] as String,
    );
  }

  // Для отладки
  @override
  String toString() {
    return 'Task(id: $id, title: $title, completed: $isCompleted, userId: $userId)';
  }
}