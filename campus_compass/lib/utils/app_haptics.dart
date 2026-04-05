import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppHaptics {
  AppHaptics._();

  static void selection() => _run(HapticFeedback.lightImpact);

  static void light() => _run(HapticFeedback.mediumImpact);

  static void medium() => _run(HapticFeedback.heavyImpact);

  static void heavy() => _run(HapticFeedback.vibrate);

  static void _run(Future<void> Function() hapticCall) {
    if (kIsWeb) {
      return;
    }
    unawaited(_safeInvoke(hapticCall));
  }

  static Future<void> _safeInvoke(Future<void> Function() hapticCall) async {
    try {
      await hapticCall();
    } catch (_) {
      // Ignore unsupported haptic capabilities on certain devices.
    }
  }
}