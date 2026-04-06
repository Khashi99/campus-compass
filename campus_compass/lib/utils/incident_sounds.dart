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
  static const String _onboardingSoundKey = 'profile_onboarding_sound';
  static const String soundTypeKey = 'profile_onboarding_sound_type';
  static const String oneBeepSoundType = 'one_beep';
  static const String twoBeepSoundType = 'two_beep';

  // Legacy values kept for migration from older app versions.
  static const String _legacyClassicSoundType = 'classic';
  static const String _legacyDoubleBeepSoundType = 'double_beep';
  static const String _legacyTripleBeepSoundType = 'triple_beep';
  static const String _legacyPulseSoundType = 'pulse';
  static const String _legacyChimeSoundType = 'chime';
  static const String _legacyBeaconSoundType = 'beacon';

  static Future<void> playForEvent(
    IncidentSoundEvent event, {
    bool force = false,
  }) async {
    if (!force && !await _allowsSound()) {
      return;
    }

    await _playToneForType(await _resolveSoundType());
  }

  static Future<void> playTestTone({
    bool ignorePreferences = false,
    String? soundType,
  }) async {
    if (!ignorePreferences && !await _allowsSound()) {
      return;
    }
    await _playToneForType(soundType ?? await _resolveSoundType());
  }

  static bool isValidSoundType(String? soundType) {
    return soundType == oneBeepSoundType ||
      soundType == twoBeepSoundType ||
        soundType == _legacyClassicSoundType ||
        soundType == _legacyDoubleBeepSoundType ||
      soundType == _legacyTripleBeepSoundType ||
      soundType == _legacyPulseSoundType ||
      soundType == _legacyChimeSoundType ||
      soundType == _legacyBeaconSoundType;
  }

  static Future<bool> _allowsSound() async {
    final prefs = await SharedPreferences.getInstance();

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

  static Future<String> _resolveSoundType() async {
    final prefs = await SharedPreferences.getInstance();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final alertPreference =
            userDoc.data()?['alertPreference'] as Map<String, dynamic>?;
        final remoteType = alertPreference?['soundType'];
        if (remoteType is String && isValidSoundType(remoteType)) {
          return _normalizeSoundType(remoteType);
        }
      } catch (_) {
        // Fall back to local setting if remote fetch fails.
      }
    }

    final storedType = prefs.getString(soundTypeKey);
    if (isValidSoundType(storedType)) {
      return _normalizeSoundType(storedType!);
    }
    return oneBeepSoundType;
  }

  static Future<void> _playToneForType(String soundType) async {
    final normalized = _normalizeSoundType(soundType);
    if (normalized == twoBeepSoundType) {
      await _playPattern([
        _ToneStep(SystemSoundType.alert, 120),
        _ToneStep(SystemSoundType.alert, 0),
      ]);
      return;
    }
    await _playPattern([
      _ToneStep(SystemSoundType.alert, 0),
    ]);
  }

  static String _normalizeSoundType(String soundType) {
    switch (soundType) {
      case _legacyClassicSoundType:
      case _legacyPulseSoundType:
        return oneBeepSoundType;
      case _legacyDoubleBeepSoundType:
      case _legacyTripleBeepSoundType:
      case _legacyChimeSoundType:
      case _legacyBeaconSoundType:
        return twoBeepSoundType;
      default:
        return soundType;
    }
  }

  static Future<void> _playPattern(List<_ToneStep> steps) async {
    if (steps.isEmpty) {
      return;
    }

    if (kIsWeb) {
      final played = await playBrowserAlertTone(steps.length);
      if (played) {
        return;
      }
    }

    for (final step in steps) {
      try {
        await SystemSound.play(step.soundType);
      } catch (_) {
        return;
      }

      if (step.delayMs > 0) {
        await Future<void>.delayed(Duration(milliseconds: step.delayMs));
      }
    }
  }

}

class _ToneStep {
  const _ToneStep(this.soundType, this.delayMs);

  final SystemSoundType soundType;
  final int delayMs;
}