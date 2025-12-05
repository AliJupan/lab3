import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lab3/services/notification_service.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/meals_screen.dart';
import 'screens/meal_detail_screen.dart';
import 'screens/favorite_screen.dart';
import 'models/meal_model.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  print("Background notification title: ${message.notification?.title}");
  print("Background notification body: ${message.notification?.body}");
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission: ${settings.authorizationStatus}');

    final fcmToken = await messaging.getToken();
    print("FCM Token: $fcmToken");
    print("Save this token to send notifications from Firebase Console!");

    messaging.onTokenRefresh.listen((newToken) {
      print("FCM Token refreshed: $newToken");
    }).onError((err) {
      print("Error refreshing FCM token: $err");
    });
  } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print('User denied permission');
  }

  try {
    await setupLocalNotifications();
    await scheduleDailyRecipeNotification();
  } catch (e) {
    print("Error setting up notifications: $e");
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📱 Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message notification: ${message.notification!.title}');

      showFCMNotification(
        message.notification!.title ?? 'New Message',
        message.notification!.body ?? '',
        message.data,
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📲 Notification opened app from background!');
    _handleNotificationTap(message.data);
  });

  final initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    print('📲 App opened from terminated state via notification!');
    // Handle the initial message after a delay to ensure app is ready
    Future.delayed(const Duration(seconds: 1), () {
      _handleNotificationTap(initialMessage.data);
    });
  }

  runApp(const MealApp());
}

void _handleNotificationTap(Map<String, dynamic> data) {
  print('Handling notification tap with data: $data');

  // Navigate based on payload
  if (data.containsKey('route')) {
    final route = data['route'];
    navigatorKey.currentState?.pushNamed(route);
  } else {
    // Default: navigate to home
    navigatorKey.currentState?.pushNamed('/');
  }
}

class MealApp extends StatefulWidget {
  const MealApp({super.key});

  @override
  State<MealApp> createState() => _MealAppState();
}

class _MealAppState extends State<MealApp> {
  final Set<Meal> _favoriteMeals = {};

  void _toggleFavorite(Meal meal) {
    setState(() {
      if (_favoriteMeals.contains(meal)) {
        _favoriteMeals.remove(meal);
      } else {
        _favoriteMeals.add(meal);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TheMealDB',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(
          favoriteMeals: _favoriteMeals,
          onToggleFavorite: _toggleFavorite,
        ),
        '/category_meals': (context) => MealsScreen(
          favoriteMeals: _favoriteMeals,
          onToggleFavorite: _toggleFavorite,
        ),
        '/details': (context) => const MealDetailScreen(),
        '/favorites': (context) => FavoritesScreen(
          favoriteMeals: _favoriteMeals.toList(),
          onToggleFavorite: _toggleFavorite,
        ),
      },
    );
  }
}