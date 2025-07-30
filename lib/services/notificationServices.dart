import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationServices {
  final messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void requestNotificationPermision() async {
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User Granted Permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User Granted Provisional Permission');
    } else {
      print('User denied Permission');
    }
  }

  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    var androidInitialization =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitialization = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: androidInitialization,
      iOS: iosInitialization,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
          print(payload.toString());
        });
  }

  void firebaseInit() {
    //terminated state
    FirebaseMessaging.instance.getInitialMessage().then((event) {
      if (event != null) {
        showNotification(event);
        // notificationMsg =
        //     '${event.notification!.title} ${event.notification!.body} I am coming from Terminated State';
      }
    });
    //foreground state
    FirebaseMessaging.onMessage.listen((event) {
      showNotification(event);
      // notificationMsg =
      //     '${event.notification!.title} ${event.notification!.body} I am coming from foreground';
    });
    //background state
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      showNotification(event);
      // notificationMsg =
      //     '${event.notification!.title} ${event.notification!.body} I am coming from background';
    });
  }

  void showNotification(RemoteMessage message) async {
    const channel = AndroidNotificationChannel(
      'com.safezone.safezone',
      'High Importance notification',
      importance: Importance.max,
    );

    final androidNotificationDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: 'Your Channel Description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher',
    );

    const darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      notificationDetails,
    );
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    messaging.onTokenRefresh.listen((event) {
      token = event.toString();
    });
    return token!;
  }
}