# Campus Compass Backend

This folder scaffolds a Firebase-first backend for the current Flutter prototype.
The implementation is now Python-based and split into feature modules instead of one large file.

## What the backend does for this project

For Campus Compass, the backend is the system of record behind the UI. It is responsible for:

- Storing active incidents that should appear on the live map.
- Tracking the current campus status (`normal`, `caution`, `highRisk`).
- Recording community trust votes and update requests.
- Storing staff-authored incident updates that feed the "Community Insights" section.
- Saving each user's alert preferences.
- Powering notifications and future moderation workflows.

The current Flutter app is still using local sample data, but the UI already points to these backend responsibilities in comments and button actions.

## Why Firebase fits

Firebase is a strong fit for this project because the app mostly needs realtime data distribution, validation, and light workflow logic:

- `Cloud Firestore`: realtime incident and campus status data for the map screen.
- `Cloud Functions`: controlled writes for incident reporting, trust votes, alert updates, and derived campus state.
- `Firebase Authentication`: anonymous auth at first, then student/staff/admin roles later.
- `Firebase Cloud Messaging`: push alerts when a campus moves into caution or high risk.
- `Cloud Storage`: optional photo uploads for incident evidence later.

The main limitation is routing. Firebase is not a route-planning engine by itself. For an MVP, the client can compute safe paths from a static campus graph plus Firestore danger zones. If you later need serious pathfinding or geospatial search, add a dedicated routing service or move that logic into a specialized backend service.

## Proposed data model

### `campusState/{campusId}`

- `status`: `normal | caution | highRisk`
- `headline`: short banner text for the map screen
- `activeIncidentCount`
- `activeIncidentIds`
- `updatedAt`

### `incidents/{incidentId}`

- `title`
- `description`
- `location`
- `coordinates.latitude`
- `coordinates.longitude`
- `campusId`
- `buildingCode`
- `type`
- `status`
- `verificationLevel`: `unverified | userReported | verified`
- `userReports`
- `verificationProgress`
- `confirmCount`
- `disputeCount`
- `updateRequestCount`
- `severity`
- `zoneRadiusMeters`
- `isActive`
- `createdBy`
- `reportedTime`
- `updatedAt`
- `resolvedAt`

### `incidents/{incidentId}/updates/{updateId}`

- `authorName`
- `authorRole`
- `content`
- `postedTime`

### `incidents/{incidentId}/trustVotes/{uid}`

- `vote`: `confirm | dispute`
- `submittedAt`
- `updatedAt`

### `incidents/{incidentId}/updateRequests/{uid}`

- `message`
- `requestedAt`
- `updatedAt`

### `incidents/{incidentId}/reports/{uid}`

- The original user-submitted incident report payload for auditing and moderation.

### `users/{uid}`

- `displayName`
- `role`
- `alertPreference.mode`
- `alertPreference.quietHours`
- `createdAt`
- `updatedAt`

## How the current app maps to the backend

- `MapScreen`: subscribe to `campusState/{campusId}` and query active incidents for that campus.
- `IncidentDetailScreen`: read `incidents/{incidentId}` and the `updates` subcollection.
- `REPORT TRUST`: call `submitTrustVote`.
- `Request Alert Update`: call `requestIncidentUpdate`.
- Onboarding alert style: call `setAlertPreferences`.

## Backend structure

- [`backend/functions/main.py`](/mnt/d/Concordia/winter_2026/soen_6571/campus-compass/backend/functions/main.py): Firebase entrypoint that re-exports the deployed functions.
- [`backend/functions/app/auth.py`](/mnt/d/Concordia/winter_2026/soen_6571/campus-compass/backend/functions/app/auth.py): backend-side auth and role checks.
- [`backend/functions/app/validation.py`](/mnt/d/Concordia/winter_2026/soen_6571/campus-compass/backend/functions/app/validation.py): request validation and shared input parsing.
- [`backend/functions/app/reporting.py`](/mnt/d/Concordia/winter_2026/soen_6571/campus-compass/backend/functions/app/reporting.py): reporting, trust votes, and staff updates.
- [`backend/functions/app/preferences.py`](/mnt/d/Concordia/winter_2026/soen_6571/campus-compass/backend/functions/app/preferences.py): alert preference writes.
- [`backend/functions/app/campus_state.py`](/mnt/d/Concordia/winter_2026/soen_6571/campus-compass/backend/functions/app/campus_state.py): derived campus-state logic and verification calculations.
- [`backend/functions/app/triggers.py`](/mnt/d/Concordia/winter_2026/soen_6571/campus-compass/backend/functions/app/triggers.py): Firestore-triggered campus-state syncing.

This is the kind of split you were asking for: auth concerns, reporting workflows, user preferences, and shared domain logic each have their own place. If routing becomes a real backend feature later, add a separate `routing.py` or `routing/` package rather than mixing it into reporting.

## Implemented functions

The scaffolded functions exported through [`backend/functions/main.py`](/mnt/d/Concordia/winter_2026/soen_6571/campus-compass/backend/functions/main.py) cover the current product flows:

- `reportIncident`
- `submitTrustVote`
- `requestIncidentUpdate`
- `postIncidentUpdate`
- `setAlertPreferences`
- `syncCampusStateOnIncidentWrite` trigger

## Setup

1. Create a Firebase project.
2. Enable Authentication, Firestore, and Cloud Functions.
3. Copy [`backend/.firebaserc.example`](/mnt/d/Concordia/winter_2026/soen_6571/campus-compass/backend/.firebaserc.example) to `.firebaserc` and replace the placeholder project ID.
4. From [`backend`](/mnt/d/Concordia/winter_2026/soen_6571/campus-compass/backend), run `firebase login`.
5. From [`backend/functions`](/mnt/d/Concordia/winter_2026/soen_6571/campus-compass/backend/functions), create a virtual environment and install dependencies:
   `python -m venv .venv`
   `source .venv/bin/activate`
   `pip install -r requirements.txt`
6. From [`backend`](/mnt/d/Concordia/winter_2026/soen_6571/campus-compass/backend), deploy with `firebase deploy --only firestore,functions`.

## Frontend integration order

1. Add Firebase to the Flutter app: `firebase_core`, `cloud_firestore`, `firebase_auth`, `cloud_functions`, and later `firebase_messaging`.
2. Replace `SampleData` usage with a repository that listens to `campusState` and `incidents`.
3. Swap the trust/update buttons to Cloud Functions calls.
4. Persist onboarding alert preferences to `users/{uid}`.
5. Decide whether route calculation stays on-device or moves to a function/service.

## Notes

- Keep direct client writes to incident root documents disabled. Use callable functions for validation and abuse control.
- Start with anonymous auth if login friction is a concern, then add staff/admin roles via custom claims. Sign-in itself should stay in Firebase Auth, not in custom backend code.
- Store Concordia building codes and static walkable graph data separately once safe routing becomes a priority.
