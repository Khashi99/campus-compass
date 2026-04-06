import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'web_vibration_api_stub.dart'
    if (dart.library.js_interop) 'web_vibration_api_web.dart';

enum IncidentHapticEvent {
  reportSubmitted,
  reportApproved,
  reportedToInvestigating,
  escalatedToVerifiedOrResolved,
  campusStatusChanged,
}

class IncidentHaptics {
  static const String _alertStylePreferenceKey = 'profile_alert_style';
  static const String _hapticPulseCountKey = 'profile_haptic_pulse_count';

  static Future<void> playForEvent(IncidentHapticEvent event) async {
    final prefs = await SharedPreferences.getInstance();
    final alertStyle = _resolveAlertStyle(
      prefs.getString(_alertStylePreferenceKey),
    );
    final allowsHaptics =
        alertStyle == 'haptic' || alertStyle == 'haptic_visual';

    if (!allowsHaptics) {
      return;
    }

    final configuredPulseCount = _sanitizePulseCount(
      prefs.getInt(_hapticPulseCountKey),
    );

    final pulseCount = switch (event) {
      IncidentHapticEvent.reportSubmitted => configuredPulseCount,
      IncidentHapticEvent.reportApproved => configuredPulseCount,
      IncidentHapticEvent.reportedToInvestigating => 1,
      IncidentHapticEvent.escalatedToVerifiedOrResolved => 2,
      IncidentHapticEvent.campusStatusChanged => configuredPulseCount,
    };

    if (kIsWeb) {
      final webSucceeded = await vibrateWithPattern(
        _patternForPulseCount(pulseCount),
      );
      // Debug: log web vibration result for troubleshooting
      try {
        // ignore: avoid_print
        print('IncidentHaptics: web vibrate result: $webSucceeded (pattern=${_patternForPulseCount(pulseCount)})');
      } catch (_) {}
      if (webSucceeded) {
        return;
      }
    }

    await _fallbackImpact(pulseCount);
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

  static int _sanitizePulseCount(int? value) {
    if (value == 2) {
      return 2;
    }
    return 1;
  }

  static List<int> _patternForPulseCount(int pulseCount) {
    // Make vibrations 1 second longer and play two pulses.
    // Base durations from previous implementation (+1s added):
    final int singleDur = 80 + 1000; // 1080ms
    final int doubleDur = 90 + 1000; // 1090ms

    // Return a two-pulse pattern: vibrate, pause, vibrate
    if (pulseCount == 2) {
      return [doubleDur, 140, doubleDur];
    }
    return [singleDur, 140, singleDur];
  }

  static Future<void> _fallbackImpact(int pulseCount) async {
    // Use heavier impact and emulate two longer pulses via delays.
    await HapticFeedback.heavyImpact();
    // Wait 1 second between impacts to mirror the longer vibration length.
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    await HapticFeedback.heavyImpact();
  }
}
