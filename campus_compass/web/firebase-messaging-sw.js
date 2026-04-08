/*
  Firebase Messaging Service Worker

  1) Copy your Firebase web config values from `firebase_options.dart` (or Firebase console)
     and replace the values in `firebaseConfig` below.

  2) Place this file at `web/firebase-messaging-sw.js` (done).

  3) Obtain your Web Push certificate (public VAPID key) from Firebase Console
     (Project Settings → Cloud Messaging → Web Push certificates). In your Flutter web
     app call `FirebaseMessaging.instance.getToken(vapidKey: '<PUBLIC_KEY>')` and save the
     token or verify it prints during startup.

  This service worker listens for background messages and shows notifications.
*/

importScripts('https://www.gstatic.com/firebasejs/9.22.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.2/firebase-messaging-compat.js');

const firebaseConfig = {
    apiKey: 'AIzaSyBz4zxuTaZyMe-gMC3ezp3Q7i7UaEKueqs',
    appId: '1:624617651104:web:ded67b330b52a81e5742c5',
    messagingSenderId: '624617651104',
    projectId: 'campus-compas-soen6751',
    authDomain: 'campus-compas-soen6751.firebaseapp.com',
    storageBucket: 'campus-compas-soen6751.firebasestorage.app',
    measurementId: 'G-9SQJ4VMM7M',
};

if (!firebase.apps.length) {
  firebase.initializeApp(firebaseConfig);
}

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = (payload.notification && payload.notification.title) || 'Incident update';
  const notificationOptions = {
    body: (payload.notification && payload.notification.body) || payload.data?.body || '',
    // Provide an icon path available under `web/`.
    icon: '/icons/Icon-192.png'
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});
