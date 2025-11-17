import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

/// Провайдер для NotificationService (Singleton)
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

