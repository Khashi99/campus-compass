const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Trigger on any update to an incident document and send an FCM topic notification.
exports.sendIncidentStatusUpdate = functions.firestore
  .document('incidents/{incidentId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data() || {};
    const after = change.after.data() || {};

    const beforeStatus = before.status || '';
    const afterStatus = after.status || '';

    if (beforeStatus === afterStatus) {
      return null; // no status change
    }

    const title = (after.title || 'Incident update');
    const body = `Status changed: ${beforeStatus} → ${afterStatus}`;

    const message = {
      topic: 'incidents',
      notification: {
        title,
        body,
      },
      data: {
        incidentId: context.params.incidentId,
        before: beforeStatus,
        after: afterStatus,
      },
      android: {
        priority: 'high'
      },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log('Sent incident update message:', response);
    } catch (err) {
      console.error('Error sending message:', err);
    }

    return null;
  });
