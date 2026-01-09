from django.apps import AppConfig


class ItemsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "items"
    
    def ready(self):
        """Import signals when app is ready."""
        import items.signals  # noqa: F401
