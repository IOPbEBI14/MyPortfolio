import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

final firebaseTaskRepositoryProvider = Provider<FirebaseTaskRepository>((ref) {
  return FirebaseTaskRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

class FirebaseTaskRepository implements TaskRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseTaskRepository(this._firestore, this._auth);

  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firestore.collection('tasks');

  String? get _currentUserId => _auth.currentUser?.uid;

  @override
  Stream<List<Task>> getTasks(String userId) {
    return _tasksCollection
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  @override
  Future<Task?> getTaskById(String taskId) async {
    final doc = await _tasksCollection.doc(taskId).get();
    if (doc.exists) {
      return Task.fromFirestore(doc.id, doc.data()!);
    }
    return null;
  }

  @override
  Future<void> createTask(Task task) async {
    await _tasksCollection.doc(task.id).set(task.toFirestore());
  }

  @override
  Future<void> updateTask(Task task) async {
    await _tasksCollection.doc(task.id).update(task.toFirestore());
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
        .map((snapshot) => snapshot.docs
        .map((doc) => Task.fromFirestore(doc.id, doc.data()))
        .toList());
  }

  @override
  Future<void> syncTasks(String userId) async {
    // Для Firebase репозитория синхронизация не требуется
    return;
  }
}