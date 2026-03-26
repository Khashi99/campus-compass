import 'package:flutter/widgets.dart';

class MapHighlightPosition {
  static const Offset defaultPosition = Offset(30, 30);

  static const Offset _lounge = Offset(18, 26);
  static const Offset _hiveCafe = Offset(118, 26);
  static const Offset _hojoConcordia = Offset(270, 26);
  static const Offset _studentAssociation = Offset(430, 44);
  static const Offset _escalators = Offset(78, 170);
  static const Offset _presentationBooths = Offset(260, 256);
  static const Offset _reggiesPub = Offset(312, 360);
  static const Offset _hallEntrance = Offset(24, 300);

  static Offset forIncidentLocation(String? location) {
    final normalized = (location ?? '').toLowerCase();

    if (_containsAny(normalized, ['lounge'])) {
      return _lounge;
    }

    if (_containsAny(normalized, ['hive', 'cafe', 'café'])) {
      return _hiveCafe;
    }

    if (_containsAny(normalized, ['hojo', 'ho jo', 'concordia'])) {
      return _hojoConcordia;
    }

    if (_containsAny(normalized, ['student association', 'association offices'])) {
      return _studentAssociation;
    }

    if (_containsAny(normalized, ['escalator', 'escalators'])) {
      return _escalators;
    }

    if (_containsAny(normalized, ['presentation booth', 'presentation booths'])) {
      return _presentationBooths;
    }

    if (_containsAny(normalized, ["reggie", 'reggies', 'regiies', 'pub'])) {
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