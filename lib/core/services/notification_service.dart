import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click if needed
      },
    );

    // Create the high importance channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminders_alarm',
      'Daily Habit Reminders',
      description: 'Insistent notifications to help you build a logging habit',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
      enableLights: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<bool> requestPermissions() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final bool? grantedNotification = await androidImplementation
        ?.requestNotificationsPermission();
    final bool? grantedExactAlarm = await androidImplementation
        ?.requestExactAlarmsPermission();

    return (grantedNotification ?? false) && (grantedExactAlarm ?? false);
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_alarm',
          'Daily Habit Reminders',
          channelDescription:
              'Insistent notifications to help you build a logging habit',
          importance: Importance.max,
          priority: Priority.max,
          ticker: 'ticker',
          styleInformation: BigTextStyleInformation(body),
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          additionalFlags: Int32List.fromList([4]),
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showTestNotification() async {
    await _notifications.show(
      999,
      'MindSpend Reminder Test',
      'This is how your mildly invasive reminder looks! 🚀',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_alarm',
          'Daily Habit Reminders',
          importance: Importance.max,
          priority: Priority.max,
          styleInformation: const BigTextStyleInformation(
            'This is a high priority insistent notification to help you stay mindful of your spending.',
          ),
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          additionalFlags: Int32List.fromList([4]),
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
