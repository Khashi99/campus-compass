import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'web_sound_api_stub.dart'
  if (dart.library.js_interop) 'web_sound_api_web.dart';

enum IncidentSoundEvent {
  reportSubmitted,
  reportApproved,
  reportedToInvestigating,
  escalatedToVerifiedOrResolved,
}

class IncidentSounds {
  static const String _alertStylePreferenceKey = 'profile_alert_style';
  static const String _onboardingSoundKey = 'profile_onboarding_sound';

  static Future<void> playForEvent(IncidentSoundEvent event) async {
    if (!await _allowsSound()) {
      return;
    }

    // Sound feedback stays a single short beep for all lifecycle events.
    await _playSystemAlert(1);
  }

  static Future<void> playTestTone({bool ignorePreferences = false}) async {
    if (!ignorePreferences && !await _allowsSound()) {
      return;
    }
    await _playSystemAlert(1);
  }

  static Future<bool> _allowsSound() async {
    final prefs = await SharedPreferences.getInstance();
    final alertStyle = _resolveAlertStyle(
      prefs.getString(_alertStylePreferenceKey),
    );
    if (alertStyle == 'silent') {
      return false;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final alertPreference =
            userDoc.data()?['alertPreference'] as Map<String, dynamic>?;
        final remoteSound = alertPreference?['sound'];
        if (remoteSound is bool) {
          return remoteSound;
        }
      } catch (_) {
        // Fall back to local setting if remote fetch fails.
      }
    }

    return prefs.getBool(_onboardingSoundKey) ?? true;
  }

  static String _resolveAlertStyle(String? style) {
    if (style == 'haptic' ||
        style == 'haptic_visual' ||
        style == 'visual' ||
        style == 'silent') {
      return style!;
    }
    return 'haptic_visual';
  }

  static Future<void> _playSystemAlert(int count) async {
    if (kIsWeb) {
      final played = await playBrowserAlertTone(count);
      if (played) {
        return;
      }
    }

    for (var i = 0; i < count; i++) {
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {
        return;
      }
      if (i < count - 1) {
        await Future<void>.delayed(const Duration(milliseconds: 110));
      }
    }
  }
}