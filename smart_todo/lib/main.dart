import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_todo/core/constants/firebase_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_todo/data/models/task_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: MyFirebaseConstants.firebaseConfig['apiKey']!,
      authDomain: MyFirebaseConstants.firebaseConfig['authDomain']!,
      projectId: MyFirebaseConstants.firebaseConfig['projectId']!,
      storageBucket: MyFirebaseConstants.firebaseConfig['storageBucket']!,
      messagingSenderId: MyFirebaseConstants.firebaseConfig['messagingSenderId']!,
      appId: MyFirebaseConstants.firebaseConfig['appId']!,
    ),
  );
  
// Инициализация Hive
  await Hive.initFlutter();
  
  // Регистрация адаптеров
  Hive.registerAdapter(TaskPriorityAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  
  // Открытие бокса для задач
  await Hive.openBox<TaskModel>('tasks');
    
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Todo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Smart Todo App - Development in Progress'),
        ),
      ),
    );
  }
}