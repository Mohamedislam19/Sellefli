#!/usr/bin/env python
"""Lightweight Django entrypoint; settings live in settings.py."""
import os
import sys


def main() -> None:
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "settings")
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Django is not installed. Install dependencies before running the server."
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == "__main__":
    main()
