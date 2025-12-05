import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../main.dart' show navigatorKey;
import '../services/api_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
final ApiService _api = ApiService();

Future<void> setupLocalNotifications() async {
  tz.initializeTimeZones();

  final dynamic locationName = await FlutterTimezone.getLocalTimezone();

  String timeZoneName;
  try {
    if (locationName is String) {
      timeZoneName = locationName;
    } else {
      timeZoneName = locationName.identifier;
    }
  } catch (e) {
    print("Error parsing timezone: $e");
    timeZoneName = 'UTC';
  }

  try {
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    print("Timezone set to: $timeZoneName");
  } catch (e) {
    print("Could not set local location: $e");
    tz.setLocalLocation(tz.getLocation('UTC'));
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin =
  DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse details) async {
      print('Local notification tapped!');
      print('Notification payload: ${details.payload}');

      if (details.payload == 'random_recipe') {
        print('User tapped daily recipe notification - fetching random meal...');

        final apiService = ApiService();
        final randomMeal = await apiService.getRandomMeal();

        if (randomMeal != null) {
          print('Random meal fetched: ${randomMeal.name}');
          navigatorKey.currentState?.pushNamed('/details', arguments: randomMeal);
        } else {
          print('Failed to fetch random meal');
          navigatorKey.currentState?.pushNamed('/');
        }
      }
    },
  );
  print('Local notifications initialized successfully');
}

Future<void> showFCMNotification(
    String title,
    String body,
    Map<String, dynamic> data,
    ) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'fcm_default_channel',
    'FCM Notifications',
    channelDescription: 'Firebase Cloud Messaging notifications',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
    icon: '@mipmap/ic_launcher',
  );

  const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
    iOS: iOSDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecond,
    title,
    body,
    platformDetails,
    payload: data['route'] ?? 'default',
  );
}

Future<void> scheduleDailyRecipeNotification() async {
  await flutterLocalNotificationsPlugin.cancel(0);

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'daily_recipe_id',
    'Daily Recipe Reminder',
    channelDescription: 'Reminder to check the recipe of the day.',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const NotificationDetails platformDetails =
  NotificationDetails(android: androidDetails, iOS: iOSDetails);

  final scheduledTime = _nextInstanceOfNotification();

  print('--- Notification Scheduling Log ---');
  print('Current Timezone: ${tz.local.name}');
  print('Current Local Time: ${tz.TZDateTime.now(tz.local)}');
  print('Notification Scheduled For: $scheduledTime');
  print('-----------------------------------');

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    '🍽️ Recipe of the Day Awaits!',
    'Tap to see your random dinner inspiration for tonight!',
    scheduledTime,
    platformDetails,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
    payload: 'random_recipe',
  );

  print('✅ Daily recipe notification scheduled successfully for 8:00 PM');
}

tz.TZDateTime _nextInstanceOfNotification() {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

  tz.TZDateTime scheduledDate =
  tz.TZDateTime(tz.local, now.year, now.month, now.day, 17, 00);

  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  return scheduledDate;
}

Future<void> sendTestNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'test_channel',
    'Test Notifications',
    channelDescription: 'Test notification channel',
    importance: Importance.max,
    priority: Priority.high,
  );

  const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();

  const NotificationDetails platformDetails =
  NotificationDetails(android: androidDetails, iOS: iOSDetails);

  await flutterLocalNotificationsPlugin.show(
    999,
    '🧪 Test Notification',
    'If you see this, notifications are working!',
    platformDetails,
    payload: 'test',
  );

  print('Test notification sent!');
}

Future<void> cancelAllNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
  print('All notifications cancelled');
}

Future<void> getPendingNotifications() async {
  final List<PendingNotificationRequest> pendingNotifications =
  await flutterLocalNotificationsPlugin.pendingNotificationRequests();

  print('Pending notifications: ${pendingNotifications.length}');
  for (var notification in pendingNotifications) {
    print('ID: ${notification.id}, Title: ${notification.title}');
  }
}