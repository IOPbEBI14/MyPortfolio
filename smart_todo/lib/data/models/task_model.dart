import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
enum TaskPriority {
  @HiveField(0)
  low,
  
  @HiveField(1)
  medium,
  
  @HiveField(2)
  high,
  
  @HiveField(3)
  urgent,
}

@HiveType(typeId: 1)
class TaskModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final TaskPriority priority;
  
  @HiveField(4)
  final DateTime? deadline;
  
  @HiveField(5)
  final List<String> tags;
  
  @HiveField(6)
  final bool isCompleted;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  final DateTime updatedAt;
  
  @HiveField(9)
  final String userId;

  TaskModel({
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

  // Копирующий конструктор с обновлениями
  TaskModel copyWith({
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
    return TaskModel(
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
  factory TaskModel.fromFirestore(String id, Map<String, dynamic> data) {
    return TaskModel(
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
}