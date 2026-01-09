"""Firebase Cloud Messaging (FCM) service for push notifications."""
import logging
from typing import Optional, Dict, Any
from django.conf import settings
import requests

logger = logging.getLogger(__name__)


class FCMService:
    """
    Service for sending push notifications via Firebase Cloud Messaging.
    
    Requires FCM_SERVER_KEY in settings.
    Get your FCM Server Key from Firebase Console > Project Settings > Cloud Messaging
    """
    
    def __init__(self):
        self.server_key = getattr(settings, 'FCM_SERVER_KEY', None)
        self.fcm_url = "https://fcm.googleapis.com/fcm/send"
        
        if not self.server_key:
            logger.warning("FCM_SERVER_KEY not configured. Push notifications disabled.")
    
    def send_notification(
        self,
        token: str,
        title: str,
        body: str,
        data: Optional[Dict[str, Any]] = None,
        priority: str = "high"
    ) -> bool:
        """
        Send push notification to a specific device.
        
        Args:
            token: FCM device token
            title: Notification title
            body: Notification body
            data: Custom data payload (must be string-keyed dict)
            priority: Notification priority ('high' or 'normal')
        
        Returns:
            True if notification sent successfully, False otherwise
        """
        if not self.server_key:
            logger.debug("FCM not configured, skipping push notification")
            return False
        
        if data is None:
            data = {}
        
        # Convert all data values to strings (FCM requirement)
        string_data = {k: str(v) for k, v in data.items()}
        
        headers = {
            "Authorization": f"key={self.server_key}",
            "Content-Type": "application/json",
        }
        
        payload = {
            "to": token,
            "priority": priority,
            "notification": {
                "title": title,
                "body": body,
                "sound": "default",
                "badge": "1",
            },
            "data": string_data,
            # Android-specific config
            "android": {
                "priority": priority,
                "notification": {
                    "sound": "default",
                    "click_action": "FLUTTER_NOTIFICATION_CLICK",
                }
            },
            # iOS-specific config
            "apns": {
                "payload": {
                    "aps": {
                        "sound": "default",
                        "badge": 1,
                        "content-available": 1,
                    }
                }
            }
        }
        
        try:
            response = requests.post(
                self.fcm_url,
                json=payload,
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                result = response.json()
                if result.get('success') == 1:
                    logger.info(f"FCM notification sent successfully to {token[:20]}...")
                    return True
                else:
                    error = result.get('results', [{}])[0].get('error', 'Unknown')
                    logger.warning(f"FCM send failed: {error}")
                    
                    # Handle invalid tokens
                    if error in ('InvalidRegistration', 'NotRegistered'):
                        self._handle_invalid_token(token)
                    
                    return False
            else:
                logger.error(f"FCM API error: {response.status_code} - {response.text}")
                return False
        
        except Exception as e:
            logger.error(f"FCM send error: {str(e)}")
            return False
    
    def send_multicast(
        self,
        tokens: list,
        title: str,
        body: str,
        data: Optional[Dict[str, Any]] = None
    ) -> Dict[str, int]:
        """
        Send notification to multiple devices.
        
        Args:
            tokens: List of FCM device tokens
            title: Notification title
            body: Notification body
            data: Custom data payload
        
        Returns:
            Dict with success and failure counts
        """
        success_count = 0
        failure_count = 0
        
        for token in tokens:
            if self.send_notification(token, title, body, data):
                success_count += 1
            else:
                failure_count += 1
        
        return {
            "success": success_count,
            "failure": failure_count,
            "total": len(tokens)
        }
    
    def _handle_invalid_token(self, token: str):
        """Mark device token as inactive when FCM reports it as invalid."""
        from .models import UserDevice
        
        try:
            device = UserDevice.objects.get(fcm_token=token)
            device.is_active = False
            device.save(update_fields=['is_active', 'updated_at'])
            logger.info(f"Marked device {device.id} as inactive due to invalid token")
        except UserDevice.DoesNotExist:
            logger.warning(f"Device with token {token[:20]}... not found in database")
