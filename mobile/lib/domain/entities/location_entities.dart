import 'package:latlong2/latlong.dart';

// Domain entity: SafeZone
class SafeZone {
  const SafeZone({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.isActive,
    this.centroid,
  });

  final int id;
  final String name;
  final String description;
  final int capacity;
  final bool isActive;
  final LatLng? centroid;
}

// Domain entity: Building
class Building {
  const Building({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.isAccessible,
    this.centroid,
  });

  final int id;
  final String name;
  final String code;
  final String address;
  final bool isAccessible;
  final LatLng? centroid;
}

// Domain entity: SafetyResource
class SafetyResource {
  const SafetyResource({
    required this.id,
    required this.resourceType,
    required this.name,
    this.phone,
    this.location,
  });

  final int id;
  final String resourceType;
  final String name;
  final String? phone;
  final LatLng? location;
}
