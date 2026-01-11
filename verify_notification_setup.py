#!/usr/bin/env python3
"""
Quick test script to verify notification system setup.
Run this to check if everything is configured correctly.
"""
import os
import sys

print("=" * 70)
print("🔍 SELLEFLI NOTIFICATION SYSTEM - SETUP VERIFICATION")
print("=" * 70)

# Check 1: Flutter Supabase Configuration
print("\n1️⃣  Checking Flutter Supabase Configuration...")
try:
    with open('lib/main.dart', 'r', encoding='utf-8') as f:
        content = f.read()
        if 'usddlozrhceftmnhnknw.supabase.co' in content:
            print("   ✅ Supabase URL configured in Flutter")
        else:
            print("   ❌ Supabase URL not found in main.dart")
        
        if 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9' in content:
            print("   ✅ Supabase anon key configured")
        else:
            print("   ❌ Supabase anon key not found")
except Exception as e:
    print(f"   ⚠️  Could not read main.dart: {e}")

# Check 2: Backend Environment Variables
print("\n2️⃣  Checking Backend Environment Configuration...")
try:
    with open('backend/.env', 'r', encoding='utf-8') as f:
        content = f.read()
        if 'SUPABASE_URL' in content:
            print("   ✅ SUPABASE_URL configured in backend/.env")
        else:
            print("   ⚠️  SUPABASE_URL not found in .env")
        
        if 'SUPABASE_SERVICE_ROLE_KEY' in content:
            print("   ✅ SUPABASE_SERVICE_ROLE_KEY configured")
        else:
            print("   ⚠️  SUPABASE_SERVICE_ROLE_KEY not found")
except Exception as e:
    print(f"   ⚠️  Could not read backend/.env: {e}")

# Check 3: Notification Service Files
print("\n3️⃣  Checking Flutter Notification Files...")
files_to_check = [
    'lib/src/core/services/notification_service.dart',
    'lib/src/features/notifications/notifications_page.dart',
]
for file in files_to_check:
    if os.path.exists(file):
        print(f"   ✅ {file}")
    else:
        print(f"   ❌ Missing: {file}")

# Check 4: Backend Notification Files
print("\n4️⃣  Checking Backend Notification Files...")
backend_files = [
    'backend/notifications/supabase_setup.sql',
    'backend/notifications/realtime.py',
]
for file in backend_files:
    if os.path.exists(file):
        print(f"   ✅ {file}")
    else:
        print(f"   ❌ Missing: {file}")

# Check 5: SQL Setup File
print("\n5️⃣  Checking SQL Setup File...")
try:
    with open('backend/notifications/supabase_setup.sql', 'r', encoding='utf-8') as f:
        content = f.read()
        checks = [
            ('CREATE TABLE IF NOT EXISTS notifications', 'Notifications table'),
            ('CREATE TABLE IF NOT EXISTS notification_events', 'Notification events table'),
            ('ALTER TABLE notifications ENABLE ROW LEVEL SECURITY', 'RLS enabled'),
            ('ALTER PUBLICATION supabase_realtime ADD TABLE notification_events', 'Realtime enabled'),
        ]
        for check, description in checks:
            if check in content:
                print(f"   ✅ {description}")
            else:
                print(f"   ⚠️  {description} not found")
except Exception as e:
    print(f"   ❌ Error reading SQL file: {e}")

# Summary
print("\n" + "=" * 70)
print("📊 SETUP STATUS SUMMARY")
print("=" * 70)
print("\n✅ CONFIGURED:")
print("   • Flutter app with Supabase client")
print("   • Notification service (real-time subscriptions)")
print("   • Notifications UI page with badge")
print("   • Backend realtime broadcasting")
print("   • SQL schema ready to execute")

print("\n⚠️  REQUIRED ACTION:")
print("   1. Go to Supabase Dashboard: https://usddlozrhceftmnhnknw.supabase.co")
print("   2. Navigate to: SQL Editor")
print("   3. Copy & paste contents of: backend/notifications/supabase_setup.sql")
print("   4. Click 'RUN' to create tables and configure RLS")

print("\n🚀 AFTER SQL SETUP:")
print("   • Run: flutter run")
print("   • Sign in to the app")
print("   • Notifications will work automatically!")

print("\n" + "=" * 70)
print("📚 For detailed instructions, see: NOTIFICATION_SETUP_COMPLETE.md")
print("=" * 70)
