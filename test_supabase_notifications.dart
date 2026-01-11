import 'package:supabase_flutter/supabase_flutter.dart';

/// Quick test to verify Supabase notifications setup
Future<void> main() async {
  print('🔍 Testing Supabase Notification Setup...\n');

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://usddlozrhceftmnhnknw.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzZGRsb3pyaGNlZnRtbmhua253Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5ODk5NTIsImV4cCI6MjA3OTU2NTk1Mn0.2K2Pum83dM_C2BGop-2Rc5IVCN8Qw4QHuIamNmmzarg',
    );

    final supabase = Supabase.instance.client;
    print('✅ Supabase client initialized\n');

    // Test 1: Check if notifications table exists
    print('Test 1: Checking if notifications table exists...');
    try {
      final notificationsTest = await supabase
          .from('notifications')
          .select('id')
          .limit(1);
      print('✅ notifications table exists');
      print('   Sample data count: ${notificationsTest.length}');
    } catch (e) {
      print('❌ notifications table NOT FOUND or not accessible');
      print('   Error: $e');
      print('\n⚠️  ACTION REQUIRED:');
      print('   1. Go to: https://usddlozrhceftmnhnknw.supabase.co');
      print('   2. Navigate to: SQL Editor');
      print('   3. Copy content from: backend/notifications/supabase_setup.sql');
      print('   4. Paste and click RUN');
      return;
    }

    // Test 2: Check if notification_events table exists
    print('\nTest 2: Checking if notification_events table exists...');
    try {
      final eventsTest = await supabase
          .from('notification_events')
          .select('id')
          .limit(1);
      print('✅ notification_events table exists');
      print('   Sample data count: ${eventsTest.length}');
    } catch (e) {
      print('❌ notification_events table NOT FOUND or not accessible');
      print('   Error: $e');
      print('\n⚠️  ACTION REQUIRED: Run the SQL setup script in Supabase');
      return;
    }

    // Test 3: Check if user_devices table exists
    print('\nTest 3: Checking if user_devices table exists...');
    try {
      final devicesTest = await supabase
          .from('user_devices')
          .select('id')
          .limit(1);
      print('✅ user_devices table exists');
      print('   Sample data count: ${devicesTest.length}');
    } catch (e) {
      print('❌ user_devices table NOT FOUND or not accessible');
      print('   Error: $e');
    }

    // Test 4: Test Realtime connection
    print('\nTest 4: Testing Realtime connection...');
    try {
      final channel = supabase
          .channel('test-channel')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notification_events',
            callback: (payload) {
              print('📬 Realtime event received: ${payload.newRecord}');
            },
          )
          .subscribe();

      print('✅ Realtime channel created successfully');
      
      // Wait a bit then unsubscribe
      await Future.delayed(Duration(seconds: 2));
      await channel.unsubscribe();
      print('✅ Realtime test complete');
    } catch (e) {
      print('❌ Realtime connection failed');
      print('   Error: $e');
      print('\n⚠️  ACTION REQUIRED:');
      print('   1. Go to: https://usddlozrhceftmnhnknw.supabase.co');
      print('   2. Navigate to: Database → Replication');
      print('   3. Enable Realtime for notification_events table');
      return;
    }

    print('\n' + '='*60);
    print('✅ ALL TESTS PASSED!');
    print('='*60);
    print('\nYour notification system is properly configured.');
    print('\nTo test end-to-end:');
    print('1. Run your Flutter app: flutter run');
    print('2. Create a notification via Django backend');
    print('3. Watch it appear in real-time!');

  } catch (e) {
    print('\n❌ SETUP FAILED');
    print('Error: $e');
    print('\nPlease check your Supabase configuration.');
  }
}
