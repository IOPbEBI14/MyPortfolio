import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

class FirebaseTaskRepository implements TaskRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseTaskRepository(this._firestore, this._auth);

  CollectionReference<Task> get _tasksCollection =>
      _firestore.collection('tasks').withConverter<Task>(
            fromFirestore: (snapshot, _) {
              final data = snapshot.data()!;
              return Task(
                id: snapshot.id,
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
            },
            toFirestore: (task, _) {
              return {
                'title': task.title,
                'description': task.description,
                'priority': task.priority.name,
                'deadline': task.deadline?.millisecondsSinceEpoch,
                'tags': task.tags,
                'isCompleted': task.isCompleted,
                'createdAt': task.createdAt.millisecondsSinceEpoch,
                'updatedAt': task.updatedAt.millisecondsSinceEpoch,
                'userId': task.userId,
              };
            },
          );

  @override
  Stream<List<Task>> getTasks(String userId) {
    return _tasksCollection
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Future<Task?> getTaskById(String taskId) async {
    final doc = await _tasksCollection.doc(taskId).get();
    return doc.data();
  }

  @override
  Future<void> createTask(Task task) async {
    await _tasksCollection.doc(task.id).set(task);
  }

  @override
  Future<void> updateTask(Task task) async {
    await _tasksCollection.doc(task.id).update({
      'title': task.title,
      'description': task.description,
      'priority': task.priority.name,
      'deadline': task.deadline?.millisecondsSinceEpoch,
      'tags': task.tags,
      'isCompleted': task.isCompleted,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  @override
  Stream<List<Task>> getTasksByFilter({
    required String userId,
    bool? isCompleted,
    String? priority,
    List<String>? tags,
  }) {
    var query = _tasksCollection.where('userId', isEqualTo: userId);

    if (isCompleted != null) {
      query = query.where('isCompleted', isEqualTo: isCompleted);
    }

    if (priority != null) {
      query = query.where('priority', isEqualTo: priority);
    }

    return query
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Future<void> syncTasks(String userId) async {
    // Для Firebase репозитория синхронизация не требуется
    return;
  }
}