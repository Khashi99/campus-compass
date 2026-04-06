import 'package:flutter/widgets.dart';

class MapHighlightPosition {
  // Coordinates are based on the original floor_plan.png pixel space.
  static const Size sourceMapSize = Size(1280, 988);
  static const Offset defaultPosition = Offset(640, 494);

  static const Offset _lounge = Offset(220, 160);
  static const Offset _hiveCafe = Offset(470, 165);
  static const Offset _hojoConcordia = Offset(700, 165);
  static const Offset _studentAssociation = Offset(900, 170);
  static const Offset _escalators = Offset(340, 390);
  static const Offset _presentationBooths = Offset(700, 540);
  static const Offset _reggiesPub = Offset(790, 760);
  static const Offset _hallEntrance = Offset(70, 360);

  static Offset forIncidentLocation(String? location) {
    final normalized = (location ?? '').toLowerCase();

    if (_containsAny(normalized, ['lounge'])) {
      return _lounge;
    }

    if (_containsAny(normalized, ['hive', 'hive cafe', 'cafe', 'café'])) {
      return _hiveCafe;
    }

    if (_containsAny(normalized, ['hojo', 'ho jo', 'hojo concordia'])) {
      return _hojoConcordia;
    }

    if (_containsAny(normalized, [
      'student association',
      'student association offices',
      'association offices',
    ])) {
      return _studentAssociation;
    }

    if (_containsAny(normalized, ['escalator', 'escalators'])) {
      return _escalators;
    }

    if (_containsAny(normalized, [
      'presentation booth',
      'presentation booths',
    ])) {
      return _presentationBooths;
    }

    if (_containsAny(normalized, [
      "reggie",
      "reggie's",
      'reggies',
      'regiies',
      'pub',
    ])) {
      return _reggiesPub;
    }

    if (_containsAny(normalized, ['hall building entrance', 'hall entrance'])) {
      return _hallEntrance;
    }

    return defaultPosition;
  }

  static bool _containsAny(String value, List<String> needles) {
    return needles.any(value.contains);
  }
}
