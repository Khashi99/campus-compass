import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppHaptics {
  AppHaptics._();

  static const String _alertStylePreferenceKey = 'profile_alert_style';
  static const Set<String> _validAlertStyles = {
    'haptic_visual',
    'visual',
    'haptic',
    'silent',
  };
  static String? _cachedAlertStyle;

  static void selection({String? alertStyleOverride, bool force = false}) =>
      _run(
        HapticFeedback.lightImpact,
        alertStyleOverride: alertStyleOverride,
        force: force,
      );

  static void light({String? alertStyleOverride, bool force = false}) => _run(
        HapticFeedback.mediumImpact,
        alertStyleOverride: alertStyleOverride,
        force: force,
      );

  static void medium({String? alertStyleOverride, bool force = false}) => _run(
        HapticFeedback.heavyImpact,
        alertStyleOverride: alertStyleOverride,
        force: force,
      );

  static void heavy({String? alertStyleOverride, bool force = false}) => _run(
        HapticFeedback.vibrate,
        alertStyleOverride: alertStyleOverride,
        force: force,
      );

  static void primeAlertStyle(String style) {
    if (_validAlertStyles.contains(style)) {
      _cachedAlertStyle = style;
    }
  }

  static void _run(
    Future<void> Function() hapticCall, {
    String? alertStyleOverride,
    required bool force,
  }) {
    unawaited(
      _runIfAllowed(
        hapticCall,
        alertStyleOverride: alertStyleOverride,
        force: force,
      ),
    );
  }

  static Future<void> _runIfAllowed(
    Future<void> Function() hapticCall, {
    String? alertStyleOverride,
    required bool force,
  }) async {
    if (kIsWeb) {
      return;
    }

    if (!force) {
      final style = await _resolveAlertStyle(alertStyleOverride);
      final allowHaptic = style == 'haptic' || style == 'haptic_visual';
      if (!allowHaptic) {
        return;
      }
    }

    await _safeInvoke(hapticCall);
  }

  static Future<String> _resolveAlertStyle(String? alertStyleOverride) async {
    if (alertStyleOverride != null && _validAlertStyles.contains(alertStyleOverride)) {
      _cachedAlertStyle = alertStyleOverride;
      return alertStyleOverride;
    }

    if (_cachedAlertStyle != null) {
      return _cachedAlertStyle!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_alertStylePreferenceKey);
      if (stored != null && _validAlertStyles.contains(stored)) {
        _cachedAlertStyle = stored;
        return stored;
      }
    } catch (_) {
      // Ignore local storage errors and fall back to default style.
    }

    _cachedAlertStyle = 'haptic_visual';
    return _cachedAlertStyle!;
  }

  static Future<void> _safeInvoke(Future<void> Function() hapticCall) async {
    try {
      await hapticCall();
    } catch (_) {
      // Ignore unsupported haptic capabilities on certain devices.
    }
  }
}