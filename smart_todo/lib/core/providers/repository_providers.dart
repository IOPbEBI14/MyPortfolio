import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../data/models/task_model.dart';
import '../../data/local/local_task_repository.dart';
import '../../data/remote/firebase_task_repository.dart';
import '../../data/repositories/sync_task_repository.dart';
import '../../domain/repositories/task_repository.dart';



// Провайдер для Hive Box
final tasksBoxProvider = Provider<Box<TaskModel>>((ref) {
  throw UnimplementedError('Будет переопределен в main');
});

// Провайдеры для Firebase сервисов
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Провайдеры репозиториев
final localTaskRepositoryProvider = Provider<TaskRepository>((ref) {
  final tasksBox = ref.watch(tasksBoxProvider);
  return LocalTaskRepository(tasksBox);
});

final firebaseTaskRepositoryProvider = Provider<FirebaseTaskRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return FirebaseTaskRepository(firestore, auth);
});

// Основной провайдер репозитория с синхронизацией
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return ref.watch(syncTaskRepositoryProvider);
});