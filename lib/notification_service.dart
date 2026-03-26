import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permisos concedidos');
    }

    String? token = await _firebaseMessaging.getToken();
    print('📱 FCM Token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Notificación: ${message.notification?.title}');
    });
  }
}
