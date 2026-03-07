import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/incident_repository.dart';
import '../../domain/entities/emergency_incident.dart';

/// Fetches and caches the list of active incidents.
final activeIncidentsProvider =
    FutureProvider.autoDispose<List<EmergencyIncident>>((ref) {
  return ref.watch(incidentRepositoryProvider).fetchActive();
});

/// Derives the overall campus status from active incidents.
final campusStatusProvider = Provider.autoDispose<CampusStatus>((ref) {
  final incidents = ref.watch(activeIncidentsProvider);
  return incidents.when(
    data: (list) {
      if (list.any((i) => i.severity == 'critical')) {
        return CampusStatus.emergency;
      } else if (list.isNotEmpty) {
        return CampusStatus.caution;
      }
      return CampusStatus.normal;
    },
    loading: () => CampusStatus.normal,
    error: (_, __) => CampusStatus.normal,
  );
});

enum CampusStatus { normal, caution, emergency }

extension CampusStatusLabel on CampusStatus {
  String get label => switch (this) {
        CampusStatus.normal => 'Campus Normal',
        CampusStatus.caution => 'Caution',
        CampusStatus.emergency => 'EMERGENCY',
      };
}
