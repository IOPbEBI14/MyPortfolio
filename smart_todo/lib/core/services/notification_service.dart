import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../domain/entities/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;

  /// Инициализация сервиса уведомлений
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Инициализация timezone
    tz.initializeTimeZones();
    
    // Настройки для Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Настройки для iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Общие настройки
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Инициализация с обработчиком нажатий
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Запрос разрешений для Android 13+
    await _requestPermissions();
    
    _isInitialized = true;
    print('✅ NotificationService initialized');
  }

  /// Запрос разрешений на уведомления
  Future<void> _requestPermissions() async {
    // Android
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }

    // iOS
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Обработчик нажатия на уведомление
  void _onNotificationTap(NotificationResponse response) {
    final taskId = response.payload;
    if (taskId != null) {
      print('📱 Notification tapped for task: $taskId');
      // TODO: Можно добавить навигацию к задаче
    }
  }

  /// Запланировать уведомления для задачи с дедлайном
  Future<void> scheduleDeadlineNotification(Task task) async {
    if (!_isInitialized) {
      print('⚠️ NotificationService not initialized');
      return;
    }

    if (task.deadline == null) return;

    final deadline = task.deadline!;
    final now = DateTime.now();

    // Отменяем старые уведомления для этой задачи
    await cancelTaskNotifications(task.id);

    // Уведомление за 1 день до дедлайна (в 9:00)
    final oneDayBefore = DateTime(
      deadline.year,
      deadline.month,
      deadline.day - 1,
      9, // 9:00
      0,
    );

    if (oneDayBefore.isAfter(now) && !task.isCompleted) {
      await _scheduleNotification(
        id: _getNotificationId(task.id, 1),
        title: '⏰ Напоминание о задаче',
        body: '${task.title}\nДедлайн завтра!',
        scheduledDate: oneDayBefore,
        payload: task.id,
      );
      print('✅ Scheduled notification 1 day before for: ${task.title}');
    }

    // Уведомление в день дедлайна (в 9:00)
    final deadlineDay = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
      9, // 9:00
      0,
    );

    if (deadlineDay.isAfter(now) && !task.isCompleted) {
      await _scheduleNotification(
        id: _getNotificationId(task.id, 2),
        title: '🔔 Дедлайн сегодня!',
        body: '${task.title}\nСрок выполнения истекает сегодня!',
        scheduledDate: deadlineDay,
        payload: task.id,
      );
      print('✅ Scheduled notification on deadline day for: ${task.title}');
    }

    // Уведомление в момент дедлайна (если время указано)
    if (deadline.hour != 0 || deadline.minute != 0) {
      if (deadline.isAfter(now) && !task.isCompleted) {
        await _scheduleNotification(
          id: _getNotificationId(task.id, 3),
          title: '⚠️ Дедлайн наступил!',
          body: '${task.title}\nВремя выполнения истекло!',
          scheduledDate: deadline,
          payload: task.id,
        );
        print('✅ Scheduled notification at deadline time for: ${task.title}');
      }
    }
  }

  /// Запланировать одно уведомление
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      const androidDetails = AndroidNotificationDetails(
        'task_deadlines', // channel ID
        'Дедлайны задач', // channel name
        channelDescription: 'Уведомления о приближающихся дедлайнах задач',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  /// Отменить все уведомления для задачи
  Future<void> cancelTaskNotifications(String taskId) async {
    if (!_isInitialized) return;

    try {
      // Отменяем все 3 возможных уведомления для задачи
      await _notifications.cancel(_getNotificationId(taskId, 1));
      await _notifications.cancel(_getNotificationId(taskId, 2));
      await _notifications.cancel(_getNotificationId(taskId, 3));
      print('✅ Cancelled notifications for task: $taskId');
    } catch (e) {
      print('❌ Error cancelling notifications: $e');
    }
  }

  /// Показать немедленное уведомление
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) return;

    const androidDetails = AndroidNotificationDetails(
      'instant_notifications',
      'Мгновенные уведомления',
      channelDescription: 'Мгновенные уведомления о событиях',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Получить уникальный ID уведомления для задачи
  /// type: 1 - за день до, 2 - в день дедлайна, 3 - в момент дедлайна
  int _getNotificationId(String taskId, int type) {
    // Используем hashCode задачи + тип уведомления
    final hash = taskId.hashCode.abs();
    return (hash % 1000000) * 10 + type;
  }

  /// Отменить все уведомления
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;
    await _notifications.cancelAll();
    print('✅ All notifications cancelled');
  }

  /// Получить список активных уведомлений
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) return [];
    return await _notifications.pendingNotificationRequests();
  }
}
