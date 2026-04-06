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
    if (pulseCount == 2) {
      // Slightly longer double-pulse for clearer feedback on phones.
      return const [90, 140, 90];
    }
    // Single longer pulse.
    return const [80];
  }

  static Future<void> _fallbackImpact(int pulseCount) async {
    // Use heavier impact and add spacing for multi-pulse feedback.
    await HapticFeedback.heavyImpact();
    if (pulseCount == 2) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.heavyImpact();
    }
  }
}
