"""Firebase app and Firestore client bootstrap."""

from firebase_admin import firestore, get_app, initialize_app

try:
    get_app()
except ValueError:
    initialize_app()

db = firestore.client()
