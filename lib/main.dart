import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://usddlozrhceftmnhnknw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzZGRsb3pyaGNlZnRtbmhua253Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5ODk5NTIsImV4cCI6MjA3OTU2NTk1Mn0.2K2Pum83dM_C2BGop-2Rc5IVCN8Qw4QHuIamNmmzarg',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(const MyApp());
}
