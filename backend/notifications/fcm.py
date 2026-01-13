import requests
import os
from django.conf import settings


class FCMService:
    """Firebase Cloud Messaging Service"""
    
    FCM_URL = 'https://fcm.googleapis.com/fcm/send'
    
    def __init__(self):
        self.server_key = os.environ.get('FCM_SERVER_KEY', getattr(settings, 'FCM_SERVER_KEY', None))
    
    def send_notification(self, token: str, title: str, body: str, data: dict = None) -> bool:
        """
        Send a push notification to a single device
        
        Args:
            token: FCM device token
            title: Notification title
            body: Notification body text
            data: Optional data payload
            
        Returns:
            bool: True if successful, False otherwise
        """
        if not self.server_key:
            print("FCM_SERVER_KEY not configured")
            return False
        
        headers = {
            'Authorization': f'key={self.server_key}',
            'Content-Type': 'application/json',
        }
        
        payload = {
            'to': token,
            'notification': {
                'title': title,
                'body': body,
                'sound': 'default',
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
            'data': data or {},
            'priority': 'high',
        }
        
        try:
            response = requests.post(self.FCM_URL, json=payload, headers=headers)
            result = response.json()
            
            if result.get('success') == 1:
                return True
            else:
                print(f"FCM send failed: {result}")
                return False
        except Exception as e:
            print(f"FCM error: {e}")
            return False
    
    def send_to_multiple(self, tokens: list, title: str, body: str, data: dict = None) -> dict:
        """
        Send push notification to multiple devices
        
        Args:
            tokens: List of FCM device tokens
            title: Notification title
            body: Notification body text
            data: Optional data payload
            
        Returns:
            dict: Results with success and failure counts
        """
        if not self.server_key:
            print("FCM_SERVER_KEY not configured")
            return {'success': 0, 'failure': len(tokens)}
        
        if not tokens:
            return {'success': 0, 'failure': 0}
        
        headers = {
            'Authorization': f'key={self.server_key}',
            'Content-Type': 'application/json',
        }
        
        payload = {
            'registration_ids': tokens[:1000],  # FCM limit
            'notification': {
                'title': title,
                'body': body,
                'sound': 'default',
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
            'data': data or {},
            'priority': 'high',
        }
        
        try:
            response = requests.post(self.FCM_URL, json=payload, headers=headers)
            result = response.json()
            
            return {
                'success': result.get('success', 0),
                'failure': result.get('failure', 0),
            }
        except Exception as e:
            print(f"FCM error: {e}")
            return {'success': 0, 'failure': len(tokens)}
    
    def send_to_topic(self, topic: str, title: str, body: str, data: dict = None) -> bool:
        """
        Send push notification to a topic
        
        Args:
            topic: Topic name (e.g., 'all_users', 'premium')
            title: Notification title
            body: Notification body text
            data: Optional data payload
            
        Returns:
            bool: True if successful, False otherwise
        """
        if not self.server_key:
            print("FCM_SERVER_KEY not configured")
            return False
        
        headers = {
            'Authorization': f'key={self.server_key}',
            'Content-Type': 'application/json',
        }
        
        payload = {
            'to': f'/topics/{topic}',
            'notification': {
                'title': title,
                'body': body,
                'sound': 'default',
            },
            'data': data or {},
            'priority': 'high',
        }
        
        try:
            response = requests.post(self.FCM_URL, json=payload, headers=headers)
            result = response.json()
            return 'message_id' in result
        except Exception as e:
            print(f"FCM topic error: {e}")
            return False


# Singleton instance
fcm_service = FCMService()
