import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:trippie_frontend/app/router.dart';
import 'package:trippie_frontend/shared/services/api_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  debugPrint('[i] FCM background: ${message.data}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channelId = 'trippie_channel';
  static const _channelName = 'Trippie Notifications';

  Future<void> initialize() async {
    if (!Platform.isAndroid) {
      debugPrint('[i] Notifications skipped on non-Android platform');
      return;
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        _navigateToTrip(response.payload);
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          importance: Importance.high,
        ),
      );
    }

    // Foreground
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[i] FCM foreground: ${message.data}');
      _showLocalNotification(message);
    });

    // Background tap
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[i] FCM tap from background: ${message.data}');
      _navigateToTrip(message.data['tripId'] as String?);
    });

    // Terminated tap
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      debugPrint('[i] FCM tap from terminated: ${initial.data}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToTrip(initial.data['tripId'] as String?);
      });
    }

    final token = await _messaging.getToken();
    debugPrint('[i] FCM token: $token');
  }

  Future<void> registerToken(ApiService apiService) async {
    if (!Platform.isAndroid) {
      return;
    }

    final token = await _messaging.getToken();
    if (token == null) {
      debugPrint('[!] FCM token is null, skipping registration');
      return;
    }

    try {
      await apiService.dio.patch(
        '/api/user/me/fcm-token',
        data: {'fcmToken': token},
      );
      debugPrint('[+] FCM token registered');
    } catch (e) {
      debugPrint('[E] FCM token registration failed: $e');
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['tripId'] as String?,
    );
  }

  void showTripCreatedNotification(String tripId, String tripName) {
    _localNotifications.show(
      tripId.hashCode,
      'Trip Created!',
      'Your trip "$tripName" was created successfully',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: tripId,
    );
    debugPrint('[+] Local notification sent for trip: $tripId');
  }

  void _navigateToTrip(String? tripId) {
    if (tripId == null || tripId.isEmpty) {
      debugPrint('[!] FCM nav: no tripId');
      return;
    }
    debugPrint('[i] navigating to trip: $tripId');
    appNavigatorKey.currentContext?.go('/home/trip/$tripId');
  }
}
