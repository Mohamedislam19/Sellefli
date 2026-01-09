"""Supabase Realtime integration for notifications."""
import logging
from typing import Optional
from django.conf import settings
import requests

logger = logging.getLogger(__name__)


class SupabaseRealtimeService:
    """
    Service for broadcasting notifications via Supabase Realtime.
    
    Uses Supabase REST API to insert into a realtime-enabled table.
    Flutter clients subscribe to this table for live updates.
    """
    
    def __init__(self):
        self.supabase_url = getattr(settings, 'SUPABASE_URL', None)
        self.service_role_key = getattr(settings, 'SUPABASE_SERVICE_ROLE_KEY', None)
        
        if not self.supabase_url or not self.service_role_key:
            logger.warning("Supabase credentials not configured. Realtime disabled.")
    
    def broadcast_notification(self, notification) -> bool:
        """
        Broadcast notification via Supabase Realtime.
        
        Creates a record in 'notification_events' table which triggers
        realtime broadcast to subscribed Flutter clients.
        
        Args:
            notification: Notification instance
        
        Returns:
            True if broadcast succeeded, False otherwise
        """
        if not self.supabase_url or not self.service_role_key:
            logger.debug("Supabase not configured, skipping realtime broadcast")
            return False
        
        try:
            url = f"{self.supabase_url}/rest/v1/notification_events"
            headers = {
                "apikey": self.service_role_key,
                "Authorization": f"Bearer {self.service_role_key}",
                "Content-Type": "application/json",
                "Prefer": "return=minimal"
            }
            
            payload = {
                "user_id": str(notification.recipient.id),
                "notification_id": str(notification.id),
                "notification_type": notification.notification_type,
                "title": notification.title,
                "body": notification.body,
                "payload": notification.payload,
                "created_at": notification.created_at.isoformat(),
            }
            
            response = requests.post(url, json=payload, headers=headers, timeout=5)
            
            if response.status_code in (200, 201):
                logger.info(f"Realtime broadcast sent for notification {notification.id}")
                return True
            else:
                logger.error(f"Realtime broadcast failed: {response.status_code} - {response.text}")
                return False
        
        except Exception as e:
            logger.error(f"Realtime broadcast error: {str(e)}")
            return False


# Add to notification creation in services.py
def trigger_realtime_broadcast(notification):
    """
    Trigger realtime broadcast for a notification.
    Call this after creating a notification.
    """
    realtime_service = SupabaseRealtimeService()
    realtime_service.broadcast_notification(notification)
