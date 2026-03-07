"""Celery application instance for Campus Compass."""

import os

from celery import Celery

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "campus_compass.settings")

app = Celery("campus_compass")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks()
