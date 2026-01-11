-- =====================================================
-- SELEFLI NOTIFICATION SYSTEM - SUPABASE SCHEMA & RLS
-- =====================================================
-- Run this in Supabase SQL Editor to set up notifications
-- with proper Row Level Security (RLS) and Realtime

-- =====================================================
-- 1. CREATE NOTIFICATIONS TABLE (if not exists)
-- =====================================================

CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    payload JSONB DEFAULT '{}',
    
    -- Read tracking
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ NULL,
    
    -- Push notification tracking
    push_sent BOOLEAN DEFAULT FALSE,
    push_sent_at TIMESTAMPTZ NULL,
    
    -- Idempotency
    idempotency_key VARCHAR(255) NULL UNIQUE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Soft delete
    deleted_at TIMESTAMPTZ NULL
);

-- =====================================================
-- 2. CREATE INDEXES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_notifications_recipient 
    ON notifications(recipient_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_recipient_unread 
    ON notifications(recipient_id, is_read, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_type 
    ON notifications(notification_type, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_idempotency 
    ON notifications(idempotency_key) 
    WHERE idempotency_key IS NOT NULL;

-- =====================================================
-- 3. CREATE NOTIFICATION_EVENTS TABLE (for Realtime)
-- =====================================================

CREATE TABLE IF NOT EXISTS notification_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    notification_id UUID NOT NULL,
    notification_type TEXT NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    payload JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notification_events_user 
    ON notification_events(user_id, created_at DESC);

-- =====================================================
-- 4. ENABLE ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS on notifications table
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Enable RLS on notification_events table
ALTER TABLE notification_events ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 5. DROP EXISTING POLICIES (if any)
-- =====================================================

DROP POLICY IF EXISTS "Users can read own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update own notification read status" ON notifications;
DROP POLICY IF EXISTS "Users can soft delete own notifications" ON notifications;
DROP POLICY IF EXISTS "Backend can insert notifications" ON notifications;

DROP POLICY IF EXISTS "Users can read own notification events" ON notification_events;
DROP POLICY IF EXISTS "Backend can insert notification events" ON notification_events;

-- =====================================================
-- 6. CREATE RLS POLICIES - NOTIFICATIONS TABLE
-- =====================================================

-- Policy 1: Users can READ their own notifications (not soft-deleted)
CREATE POLICY "Users can read own notifications"
    ON notifications
    FOR SELECT
    USING (
        recipient_id = auth.uid() AND 
        deleted_at IS NULL
    );

-- Policy 2: Users can UPDATE their own notification's read status
CREATE POLICY "Users can update own notification read status"
    ON notifications
    FOR UPDATE
    USING (recipient_id = auth.uid())
    WITH CHECK (
        recipient_id = auth.uid() AND
        -- Only allow updating is_read and read_at fields
        -- (PostgreSQL RLS doesn't check specific columns, so this is enforced in app)
        true
    );

-- Policy 3: Users can soft delete their own notifications
CREATE POLICY "Users can soft delete own notifications"
    ON notifications
    FOR UPDATE
    USING (recipient_id = auth.uid())
    WITH CHECK (
        recipient_id = auth.uid() AND
        deleted_at IS NOT NULL
    );

-- Policy 4: Backend service role can INSERT notifications
-- (Django backend uses service_role key)
CREATE POLICY "Backend can insert notifications"
    ON notifications
    FOR INSERT
    WITH CHECK (true);  -- Service role bypasses RLS, but we define this for clarity

-- =====================================================
-- 7. CREATE RLS POLICIES - NOTIFICATION_EVENTS TABLE
-- =====================================================

-- Policy 1: Users can READ their own notification events (for realtime)
CREATE POLICY "Users can read own notification events"
    ON notification_events
    FOR SELECT
    USING (user_id = auth.uid());

-- Policy 2: Backend service role can INSERT notification events
CREATE POLICY "Backend can insert notification events"
    ON notification_events
    FOR INSERT
    WITH CHECK (true);  -- Service role bypasses RLS

-- =====================================================
-- 8. ENABLE REALTIME FOR NOTIFICATIONS
-- =====================================================

-- Enable realtime publications for notification_events
-- (Users subscribe to this table to get live notifications)

ALTER PUBLICATION supabase_realtime ADD TABLE notification_events;

-- Note: notifications table itself doesn't need realtime
-- because we use notification_events as the broadcast channel

-- =====================================================
-- 9. CREATE USER_DEVICES TABLE (for FCM tokens)
-- =====================================================

CREATE TABLE IF NOT EXISTS user_devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    fcm_token VARCHAR(500) NOT NULL UNIQUE,
    device_type VARCHAR(20) NOT NULL CHECK (device_type IN ('android', 'ios', 'web')),
    device_name VARCHAR(255) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_used_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_devices_user 
    ON user_devices(user_id, is_active);

CREATE INDEX IF NOT EXISTS idx_user_devices_token 
    ON user_devices(fcm_token);

-- Enable RLS on user_devices
ALTER TABLE user_devices ENABLE ROW LEVEL SECURITY;

-- Users can manage their own devices
CREATE POLICY "Users can manage own devices"
    ON user_devices
    FOR ALL
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Backend can insert/update devices
CREATE POLICY "Backend can manage all devices"
    ON user_devices
    FOR ALL
    WITH CHECK (true);

-- =====================================================
-- 10. CREATE UPDATED_AT TRIGGER
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for notifications table
DROP TRIGGER IF EXISTS update_notifications_updated_at ON notifications;
CREATE TRIGGER update_notifications_updated_at
    BEFORE UPDATE ON notifications
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for user_devices table
DROP TRIGGER IF EXISTS update_user_devices_updated_at ON user_devices;
CREATE TRIGGER update_user_devices_updated_at
    BEFORE UPDATE ON user_devices
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 11. VERIFICATION QUERIES
-- =====================================================

-- Run these to verify setup:
-- SELECT * FROM notifications LIMIT 5;
-- SELECT * FROM notification_events LIMIT 5;
-- SELECT * FROM user_devices LIMIT 5;

-- Check RLS policies:
-- SELECT * FROM pg_policies WHERE tablename IN ('notifications', 'notification_events', 'user_devices');

-- Check realtime publications:
-- SELECT * FROM pg_publication_tables WHERE pubname = 'supabase_realtime';

-- =====================================================
-- SETUP COMPLETE ✅
-- =====================================================
