# Campus Compass

A mobile emergency guidance system that helps Concordia University students navigate to safety during campus emergencies. The app delivers real-time incident alerts, safe-route guidance, and an interactive campus map — even when network connectivity is degraded.

---

## Architecture Overview

| Layer | Technology |
|---|---|
| Mobile app | Flutter (layered architecture) |
| Backend API | Django + Django REST Framework |
| Realtime updates | Django Channels (WebSockets) |
| Push alerts | Firebase Cloud Messaging (FCM) |
| Database | PostgreSQL + PostGIS |
| Deployment | ASGI (Daphne / Uvicorn) |

---

## Repository Structure

```
campus-compass/
├── backend/          # Django backend (API, WebSockets, admin)
│   ├── campus_compass/   # Django project config
│   ├── users/            # Accounts, roles, authentication
│   ├── incidents/        # Emergency records, severity, status
│   ├── locations/        # Buildings, safe zones, route graph
│   ├── routing/          # Safest-path computation
│   ├── notifications/    # FCM push + in-app alerts
│   ├── reports/          # Student check-ins / submissions
│   ├── audit/            # Action logs
│   └── admin_ops/        # Staff dashboard helpers
├── mobile/           # Flutter app
│   ├── lib/
│   │   ├── presentation/ # Screens & widgets
│   │   ├── application/  # ViewModels / state management
│   │   ├── domain/       # Entities & business rules
│   │   └── data/         # Repositories, API clients, cache
│   └── pubspec.yaml
└── docker-compose.yml
```

---

## Key Features (MVP)

- **Emergency status banner** — normal / caution / emergency campus state
- **Campus map** — safe zones, blocked zones, exits, assembly points, first-aid
- **Safe-route guidance** — shortest safe path from current location to a safe point
- **Push notifications** — FCM alerts triggered by campus administrators
- **Live updates** — WebSocket feed while the app is open
- **Offline resilience** — cached map, safe zones, and instructions when network drops
- **Admin dashboard** — create/update incidents, manage hazard zones

---

## Getting Started

### Prerequisites
- Python 3.11+
- Flutter 3.x (Dart 3.x)
- Docker & Docker Compose (for PostgreSQL + PostGIS)
- Firebase project with FCM enabled

### Backend

```bash
cd backend
python -m venv .venv
# Windows
.venv\Scripts\activate
pip install -r requirements.txt
# Start the database
docker-compose up -d db
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

### Mobile app

```bash
cd mobile
flutter pub get
flutter run
```

---

## Data Flow

1. A campus admin marks an incident active via the staff dashboard or Django admin.
2. The backend creates the incident, marks hazard zones, and disables blocked route edges.
3. FCM push notification is dispatched to all registered devices.
4. If the app is open, a WebSocket message (via Django Channels) updates the UI instantly.
5. The Flutter app fetches the current emergency state and calls the routing API.
6. The app renders the safest route, alert details, and nearby safe destinations.
7. On network loss the app falls back to the last cached map and instructions.

---

## License

Academic project — Concordia University SOEN 6571, Winter 2026.

