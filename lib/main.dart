import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';
import 'src/core/services/api_client.dart';
import 'src/core/services/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize push notifications
  await PushNotificationService().initialize(
    onTap: (data) {
      debugPrint('Notification tapped with data: $data');
    },
    onRefresh: (token) {
      debugPrint('FCM token refreshed');
    },
  );

  await Supabase.initialize(
    url: 'https://usddlozrhceftmnhnknw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzZGRsb3pyaGNlZnRtbmhua253Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5ODk5NTIsImV4cCI6MjA3OTU2NTk1Mn0.2K2Pum83dM_C2BGop-2Rc5IVCN8Qw4QHuIamNmmzarg',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Initialize API client for Django backend communication
  await ApiClient().initialize();

  runApp(const MyApp());
}


