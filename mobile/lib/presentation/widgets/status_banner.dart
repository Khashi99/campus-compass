import 'package:flutter/material.dart';

import '../../application/providers/incident_providers.dart';

class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, required this.status});
  final CampusStatus status;

  Color get _color => switch (status) {
        CampusStatus.normal => Colors.green,
        CampusStatus.caution => Colors.orange,
        CampusStatus.emergency => Colors.red,
      };

  IconData get _icon => switch (status) {
        CampusStatus.normal => Icons.check_circle,
        CampusStatus.caution => Icons.warning_amber,
        CampusStatus.emergency => Icons.emergency,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(_icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            status.label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
        ],
      ),
    );
  }
}
