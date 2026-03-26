import 'package:flutter/material.dart';
import 'package:campus_compass/models/incident.dart';
import 'package:campus_compass/models/safety_route_step.dart';
import 'package:campus_compass/screens/alerts_screen.dart';
import 'package:campus_compass/screens/profile_screen.dart';
import 'package:campus_compass/screens/report_incident_screen.dart';
import 'package:campus_compass/widgets/route_verification_banner.dart';
import 'package:campus_compass/widgets/safety_route_step_tile.dart';
import 'package:campus_compass/widgets/safety_time_bar.dart';
import 'package:campus_compass/widgets/bottom_nav_bar.dart';
import 'package:campus_compass/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SafetyRouteScreen extends StatefulWidget {
  const SafetyRouteScreen({super.key, this.incident});

  final Incident? incident;

  @override
  State<SafetyRouteScreen> createState() => _SafetyRouteScreenState();
}

class _SafetyRouteScreenState extends State<SafetyRouteScreen> {
  static const _stairsFreeKey = 'profile_stairs_free_routing';

  int _currentNavIndex = 0;
  bool _stairsFreeRouting = false;

  @override
  void initState() {
    super.initState();
    _loadAccessibilityPreferences();
  }

  Future<void> _loadAccessibilityPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }

    setState(() {
      _stairsFreeRouting = prefs.getBool(_stairsFreeKey) ?? false;
    });
  }

  void _handleNavTap(int index) {
    if (index == _currentNavIndex) {
      return;
    }

    setState(() => _currentNavIndex = index);

    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/map', (route) => false);
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReportIncidentScreen(),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AlertsScreen(),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final incident = widget.incident;
    final steps = _stepsForIncident(incident);
    final etaMinutes = _estimatedMinutes(incident);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Safety Route',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.darkText),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.settings_outlined,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const RouteVerificationBanner(
                  text: "Verified by Campus Safety",
                ),
                SizedBox(height: 14),
                Text(
                  _guidanceText(incident),
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.mutedText,
                  ),
                ),
                SizedBox(height: 22),
                ...steps.map((step) => SafetyRouteStepTile(step: step)),
              ],
            ),
          ),
          SafetyTimeBar(
            text: 'Estimated time to safety: $etaMinutes minutes (approx.)',
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
      ),
    );
  }

  String _guidanceText(Incident? incident) {
    if (incident == null) {
      return _stairsFreeRouting
          ? 'This is an accessibility-prioritized guidance route. Follow ramps and elevator corridors highlighted in the steps.'
          : 'This is a guidance route. Please refer to nearby hallways, room numbers, and signage to connect with the path.';
    }

    final accessibilityNote = _stairsFreeRouting
        ? ' Accessibility mode is on, so stairs are avoided where possible.'
        : '';

    return 'Route generated for ${incident.location}. It avoids the ${incident.typeDisplayName.toLowerCase()} area and keeps you on monitored hallways.$accessibilityNote';
  }

  int _estimatedMinutes(Incident? incident) {
    if (incident == null) {
      return 10;
    }

    final severityPenalty = incident.severity >= 2 ? 3 : 1;
    switch (incident.type) {
      case IncidentType.emergency:
        return 14 + severityPenalty;
      case IncidentType.protest:
      case IncidentType.gathering:
        return 12 + severityPenalty;
      case IncidentType.blockage:
      case IncidentType.construction:
        return 11 + severityPenalty;
      case IncidentType.maintenance:
        return 9 + severityPenalty;
    }
  }

  List<SafetyRouteStep> _stepsForIncident(Incident? incident) {
    final start = incident?.location ?? 'your current location';

    if (incident == null) {
      return _applyAccessibilityToSteps(_defaultSteps());
    }

    switch (incident.type) {
      case IncidentType.blockage:
      case IncidentType.construction:
        return _applyAccessibilityToSteps([
          SafetyRouteStep(
            icon: Icons.arrow_upward_rounded,
            title: 'Move away from $start',
            subtitle: 'Use the nearest open corridor and avoid blocked access points.',
          ),
          const SafetyRouteStep(
            icon: Icons.turn_right_rounded,
            title: 'Turn right toward an alternate entry',
            subtitle: 'This route avoids equipment zones and temporary barriers.',
          ),
          const SafetyRouteStep(
            icon: Icons.stairs_rounded,
            title: 'Use stairs or elevator to upper passage',
            subtitle: 'Upper connectors have lower congestion and clear exits.',
          ),
          const SafetyRouteStep(
            icon: Icons.verified_user_outlined,
            title: 'Reached Safety',
            subtitle: 'You are now outside the disruption perimeter.',
            isFinalStep: true,
          ),
        ]);
      case IncidentType.protest:
      case IncidentType.gathering:
        return _applyAccessibilityToSteps([
          SafetyRouteStep(
            icon: Icons.turn_left_rounded,
            title: 'Turn away from $start activity',
            subtitle: 'Keep distance from dense crowd zones and follow side corridors.',
          ),
          const SafetyRouteStep(
            icon: Icons.arrow_upward_rounded,
            title: 'Continue through monitored hallway',
            subtitle: 'Security-monitored sections provide the fastest safe passage.',
          ),
          const SafetyRouteStep(
            icon: Icons.turn_right_rounded,
            title: 'Exit toward low-density zone',
            subtitle: 'Avoid central atriums and event-adjacent intersections.',
          ),
          const SafetyRouteStep(
            icon: Icons.verified_user_outlined,
            title: 'Reached Safety',
            subtitle: 'You are now outside the high-tension area.',
            isFinalStep: true,
          ),
        ]);
      case IncidentType.emergency:
        return _applyAccessibilityToSteps([
          SafetyRouteStep(
            icon: Icons.directions_run_rounded,
            title: 'Leave $start immediately',
            subtitle: 'Proceed calmly to the nearest marked emergency corridor.',
          ),
          const SafetyRouteStep(
            icon: Icons.arrow_upward_rounded,
            title: 'Follow emergency signage',
            subtitle: 'Use clearly marked routes and avoid elevators if instructed.',
          ),
          const SafetyRouteStep(
            icon: Icons.exit_to_app_rounded,
            title: 'Move to designated safe zone',
            subtitle: 'Stay clear of cordoned areas and keep exits unobstructed.',
          ),
          const SafetyRouteStep(
            icon: Icons.verified_user_outlined,
            title: 'Reached Safety',
            subtitle: 'You have reached a designated safe zone.',
            isFinalStep: true,
          ),
        ]);
      case IncidentType.maintenance:
        return _applyAccessibilityToSteps([
          SafetyRouteStep(
            icon: Icons.arrow_upward_rounded,
            title: 'Proceed away from $start',
            subtitle: 'Minor hazard detected. This route keeps you on clear paths.',
          ),
          const SafetyRouteStep(
            icon: Icons.turn_left_rounded,
            title: 'Use alternate corridor',
            subtitle: 'Bypassing maintenance traffic and restricted sections.',
          ),
          const SafetyRouteStep(
            icon: Icons.verified_user_outlined,
            title: 'Reached Safety',
            subtitle: 'You are now in a low-risk area.',
            isFinalStep: true,
          ),
        ]);
    }
  }

  List<SafetyRouteStep> _applyAccessibilityToSteps(List<SafetyRouteStep> steps) {
    if (!_stairsFreeRouting) {
      return steps;
    }

    return steps.map((step) {
      final hasStairs =
          step.icon == Icons.stairs_rounded ||
          step.title.toLowerCase().contains('stair') ||
          step.subtitle.toLowerCase().contains('stair') ||
          step.title.toLowerCase().contains('staircase') ||
          step.subtitle.toLowerCase().contains('staircase');

      if (!hasStairs) {
        return step;
      }

      return const SafetyRouteStep(
        icon: Icons.elevator,
        title: 'Use elevator or ramp connector',
        subtitle: 'Accessibility mode selected. Stairs are avoided on this path.',
      );
    }).toList();
  }

  List<SafetyRouteStep> _defaultSteps() {
    return const [
      SafetyRouteStep(
        icon: Icons.arrow_upward_rounded,
        title: 'Proceed toward Classroom H-110',
        subtitle: 'Crowd density in adjacent corridor detected. Your path remains clear.',
      ),
      SafetyRouteStep(
        icon: Icons.turn_left_rounded,
        title: 'Turn left toward the Elevator Lobby',
        subtitle: 'A quieter path has been selected for comfort and accessibility.',
      ),
      SafetyRouteStep(
        icon: Icons.arrow_upward_rounded,
        title: 'Continue past the Bookstore entrance',
        subtitle: 'The central atrium is under observation. This route avoids congestion.',
      ),
      SafetyRouteStep(
        icon: Icons.turn_right_rounded,
        title: 'Turn right toward the Information Desk intersection',
        subtitle: 'Minor crowd activity detected ahead.',
      ),
      SafetyRouteStep(
        icon: Icons.turn_left_rounded,
        title: 'Turn left at the next hallway',
        subtitle: 'Alternate corridor selected to maintain a calm environment.',
      ),
      SafetyRouteStep(
        icon: Icons.turn_right_rounded,
        title: 'Use the accessible entrance on your right',
        subtitle: 'Automatic door access available.',
      ),
      SafetyRouteStep(
        icon: Icons.verified_user_outlined,
        title: 'Reached Safety',
        subtitle: 'You have arrived at a safer zone.',
        isFinalStep: true,
      ),
    ];
  }
}