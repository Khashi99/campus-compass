# Campus Compass Backend

This folder now defines a Spark-plan-compatible Firebase architecture for the current Flutter prototype.

There is no Cloud Functions backend in this version. The project uses:

- `Firebase Authentication` for sign-in
- `Cloud Firestore` for data storage and realtime updates
- `Firestore Security Rules` for access control
- client-side logic for campus status calculation and any future route calculation

## What the backend does for this project

For Campus Compass, the backend is the system of record behind the UI. It is responsible for:

- storing official incidents that should appear on the live map
- storing student-submitted incident reports separately from official incidents
- recording community trust votes and update requests
- storing staff-authored incident updates that feed the "Community Insights" section
- saving each user's alert preferences

The current Flutter app is still using local sample data, but the UI already points to these backend responsibilities in comments and button actions.

## Why the architecture changed

The previous design used Cloud Functions, which requires the Blaze plan. Since you want to stay on Spark, the architecture has to avoid Functions entirely.

That changes two important things:

1. The app cannot rely on server-side automation to derive `campusState`, update counters, or validate workflows.
2. Official incidents should not be directly writable by normal users, because there is no trusted server layer to moderate or transform those writes.

So the Spark-compatible version separates:

- `incidentReports`: untrusted student submissions
- `incidents`: staff-managed official incidents shown in the app

## Why Firebase still fits

Firebase is a strong fit for this project because the app mostly needs realtime data distribution, validation, and light workflow logic:

- `Cloud Firestore`: realtime incident and campus status data for the map screen.
- `Firebase Authentication`: anonymous auth at first, then student/staff/admin roles later.
- `Firebase Cloud Messaging`: optional later, but not required for the Spark prototype.
- `Cloud Storage`: optional later for photo uploads.

The main limitation is automation. Without Functions, anything derived or moderated must either be computed on the client or handled manually by staff.

## Proposed data model

### `roles/{uid}`

- `role`: `staff | admin`

This collection is managed manually in the Firebase console for the prototype. It replaces custom claims for staff access control.

### `users/{uid}`

- `displayName`
- `alertPreference.mode`
- `alertPreference.quietHours`
- `createdAt`
- `updatedAt`

### `incidentReports/{reportId}`

- `campusId`
- `title`
- `description`
- `location`
- `coordinates.latitude`
- `coordinates.longitude`
- `buildingCode`
- `type`
- `status`: `submitted | investigating | dismissed | resolved`
- `verificationLevel`: usually `userReported`
- `createdBy`
- `linkedIncidentId`
- `reportedTime`
- `updatedAt`

This is where students submit reports. These are not automatically part of the official live incident feed.

### `incidents/{incidentId}`

- `campusId`
- `title`
- `description`
- `location`
- `coordinates.latitude`
- `coordinates.longitude`
- `buildingCode`
- `type`
- `status`: `reported | investigating | resolved`
- `verificationLevel`: `unverified | userReported | verified`
- `severity`: `1 | 2`
- `zoneRadiusMeters`
- `isActive`
- `reportedTime`
- `updatedAt`
- `resolvedAt`

These are the official incidents that the app should display on the map.

### `incidents/{incidentId}/updates/{updateId}`

- `authorName`
- `authorRole`
- `content`
- `postedTime`

### `incidents/{incidentId}/trustVotes/{uid}`

- `uid`
- `vote`: `confirm | dispute`
- `submittedAt`
- `updatedAt`

### `incidents/{incidentId}/updateRequests/{uid}`

- `uid`
- `message`
- `requestedAt`
- `updatedAt`

### Optional `campusState/{campusId}`

- `status`: `normal | caution | highRisk`
- `headline`: short banner text for the map screen
- `updatedAt`

This document is optional on Spark. The safer default is to compute campus status on the client by querying active incidents:

- no active incidents => `normal`
- any active severity-2 incident => `highRisk`
- otherwise => `caution`

## How the current app maps to the backend

- `MapScreen`: query active `incidents` for the current campus and derive campus status locally.
- `IncidentDetailScreen`: read `incidents/{incidentId}` and the `updates` subcollection.
- `REPORT TRUST`: write or update `incidents/{incidentId}/trustVotes/{uid}` directly from the app.
- `Request Alert Update`: write or update `incidents/{incidentId}/updateRequests/{uid}` directly from the app.
- Onboarding alert style: write `users/{uid}` directly from the app.
- Future report flow: create docs in `incidentReports`.

## Setup

1. Create a Firebase project.
2. Enable Authentication and Firestore.
3. Copy [`backend/.firebaserc.example`](/mnt/d/Concordia/winter_2026/soen_6571/campus-compass/backend/.firebaserc.example) to `.firebaserc` and replace the placeholder project ID.
4. From [`backend`](/mnt/d/Concordia/winter_2026/soen_6571/campus-compass/backend), run `firebase login`.
5. Deploy Firestore rules and indexes:
   `firebase deploy --only firestore`
6. In the Firebase console, create a `roles/{uid}` document for each staff member who should be allowed to manage official incidents.

## Frontend integration order

1. Add Firebase to the Flutter app: `firebase_core`, `cloud_firestore`, `firebase_auth`, and later `firebase_messaging`.
2. Replace `SampleData` usage with a repository that listens to `incidents`.
3. Derive campus status locally from active incidents.
4. Write trust votes and update requests directly to Firestore.
5. Persist onboarding alert preferences to `users/{uid}`.
6. Add an incident report form that writes to `incidentReports`.

## Notes

- Keep direct client writes to official `incidents` restricted to staff users only.
- Use anonymous auth first. On Spark, the simplest staff model is a manual `roles` collection instead of custom claims.
- Route calculation should stay on-device for this version.
- If you eventually need automatic moderation, derived counters, or automated notifications, move to Blaze and reintroduce Cloud Functions.
