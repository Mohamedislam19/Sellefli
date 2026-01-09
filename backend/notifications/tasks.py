"""Background tasks for push notifications."""
import logging
from typing import Optional
from django.conf import settings

logger = logging.getLogger(__name__)


def send_push_notification_task(notification_id: str):
    """
    Send push notification via FCM.
    
    This is a lightweight synchronous implementation.
    For production with Celery/Django-Q, convert this to:
    @shared_task or @task decorator
    
    Args:
        notification_id: UUID of notification to send
    """
    from .models import Notification, UserDevice
    from .fcm import FCMService
    from django.utils import timezone
    
    try:
        notification = Notification.objects.select_related('recipient').get(
            id=notification_id,
            push_sent=False
        )
    except Notification.DoesNotExist:
        logger.warning(f"Notification {notification_id} not found or already sent")
        return
    
    # Get active devices for user
    devices = UserDevice.objects.filter(
        user=notification.recipient,
        is_active=True
    )
    
    if not devices.exists():
        logger.info(f"No active devices for user {notification.recipient.username}")
        notification.push_sent = True
        notification.push_sent_at = timezone.now()
        notification.save(update_fields=['push_sent', 'push_sent_at', 'updated_at'])
        return
    
    # Send to all devices
    fcm_service = FCMService()
    success_count = 0
    
    for device in devices:
        try:
            success = fcm_service.send_notification(
                token=device.fcm_token,
                title=notification.title,
                body=notification.body,
                data=notification.payload
            )
            if success:
                success_count += 1
        except Exception as e:
            logger.error(f"Failed to send push to device {device.id}: {str(e)}")
    
    # Mark as sent
    notification.push_sent = True
    notification.push_sent_at = timezone.now()
    notification.save(update_fields=['push_sent', 'push_sent_at', 'updated_at'])
    
    logger.info(f"Push notification sent to {success_count}/{devices.count()} devices")
