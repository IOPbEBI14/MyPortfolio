import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_todo/core/constants/firebase_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_todo/data/models/task_model.dart';
import 'package:smart_todo/core/providers/repository_providers.dart';
import 'package:smart_todo/core/providers/auth_providers.dart';
import 'package:smart_todo/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_todo/features/auth/presentation/screens/register_screen.dart';
import 'package:smart_todo/features/tasks/presentation/screens/tasks_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Firebase с обработкой ошибок
  try {
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
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
    // Продолжаем работу даже если Firebase не инициализирован
    // Это позволит приложению работать в оффлайн режиме
  }
  
  // Инициализация Hive
  await Hive.initFlutter();
  
  // Регистрация адаптеров
  Hive.registerAdapter(TaskPriorityAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  
  // Открытие бокса для задач
  final tasksBox = await Hive.openBox<TaskModel>('tasks');
  
  runApp(
    ProviderScope(
      overrides: [
        // Переопределяем провайдер Box реальным значением
        tasksBoxProvider.overrideWithValue(tasksBox),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Smart Todo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const TasksScreen(); // Будем создавать дальше
          } else {
            return const LoginScreen();
          }
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Authentication Error',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(authStateProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}
