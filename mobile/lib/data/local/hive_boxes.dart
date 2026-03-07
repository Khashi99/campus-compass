import 'package:hive/hive.dart';

/// Names for all Hive boxes used by the app.
class HiveBoxes {
  HiveBoxes._();

  static const String incidents = 'incidents_cache';
  static const String locations = 'locations_cache';
  static const String settings = 'settings';

  static Future<void> openAll() async {
    await Hive.openBox<String>(incidents);
    await Hive.openBox<String>(locations);
    await Hive.openBox(settings);
  }
}
