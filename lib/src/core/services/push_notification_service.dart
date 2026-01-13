import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
  await PushNotificationService._showLocalNotification(message);
}

/// Service for managing Firebase Cloud Messaging push notifications
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  // Notification channel for Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'sellefli_notifications',
    'Sellefli Notifications',
    description: 'Notifications for booking updates, messages, and more',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  // Callbacks for handling notification interactions
  Function(Map<String, dynamic>)? onNotificationTap;
  Function(String)? onTokenRefresh;

  /// Initialize push notification service
  Future<void> initialize({
    Function(Map<String, dynamic>)? onTap,
    Function(String)? onRefresh,
  }) async {
    onNotificationTap = onTap;
    onTokenRefresh = onRefresh;

    // Request permission
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

    // Set up message handlers
    _setupMessageHandlers();

    // Get and store initial token
    await _getAndStoreToken();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed');
      _storeToken(newToken);
      onTokenRefresh?.call(newToken);
    });
  }

  /// Request notification permission
  Future<bool> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    debugPrint('Notification permission: ${settings.authorizationStatus}');
    return granted;
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        onNotificationTap?.call(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Set up Firebase message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message: ${message.messageId}');
      _showLocalNotification(message);
    });

    // When app is opened from a notification (background state)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened app: ${message.messageId}');
      _handleNotificationTap(message);
    });

    // Check if app was opened from a notification (terminated state)
    _checkInitialMessage();
  }

  /// Check if app was opened from notification when terminated
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state via notification');
      _handleNotificationTap(initialMessage);
    }
  }

  /// Handle notification tap from RemoteMessage
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    onNotificationTap?.call(data);
  }

  /// Show local notification for foreground/background messages
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  /// Get FCM token and store locally
  Future<String?> _getAndStoreToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _storeToken(token);
        debugPrint('FCM Token obtained');
      }
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Store token locally
  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  /// Get stored token
  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// Register device token with backend
  Future<bool> registerDeviceWithBackend({
    required String authToken,
    String? deviceName,
  }) async {
    try {
      final fcmToken = await getToken();
      if (fcmToken == null) {
        debugPrint('No FCM token available');
        return false;
      }

      final deviceType = Platform.isAndroid ? 'android' : 
                         Platform.isIOS ? 'ios' : 'web';

      final response = await ApiClient().post(
        '/api/devices/',
        body: {
          'fcm_token': fcmToken,
          'device_type': deviceType,
          'device_name': deviceName ?? '${Platform.operatingSystem} device',
          'is_active': true,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Device registered with backend');
        return true;
      } else {
        debugPrint('Failed to register device: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error registering device: $e');
      return false;
    }
  }

  /// Unregister device token from backend (on logout)
  Future<bool> unregisterDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
      return true;
    } catch (e) {
      debugPrint('Error unregistering device: $e');
      return false;
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  /// Delete token (for logout/account deletion)
  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fcm_token');
    debugPrint('FCM token deleted');
  }
}
