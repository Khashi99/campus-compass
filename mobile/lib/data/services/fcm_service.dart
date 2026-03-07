import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles FCM token registration and foreground notification display.
class FcmService {
  FcmService._();

  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Request permission (iOS / Android 13+)
    await FirebaseMessaging.instance.requestPermission();

    // Initialise local notifications for foreground display
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Show notifications when app is in foreground
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'campus_compass_alerts',
            'Emergency Alerts',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    });
  }

  static Future<String?> getToken() => FirebaseMessaging.instance.getToken();
}
