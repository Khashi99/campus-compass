import 'package:flutter/material.dart';
import 'package:campus_compass/models/safety_route_step.dart';
import 'package:campus_compass/widgets/route_verification_banner.dart';
import 'package:campus_compass/widgets/safety_route_step_tile.dart';
import 'package:campus_compass/widgets/safety_time_bar.dart';
import 'package:campus_compass/widgets/bottom_nav_bar.dart';
import 'package:campus_compass/theme/app_colors.dart';

class SafetyRouteScreen extends StatefulWidget {
  const SafetyRouteScreen({super.key});

  @override
  State<SafetyRouteScreen> createState() => _SafetyRouteScreenState();
}

class _SafetyRouteScreenState extends State<SafetyRouteScreen> {
  int _currentNavIndex = 0;

  final List<SafetyRouteStep> _steps = const [
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

  void _handleNavTap(int index) {
    setState(() => _currentNavIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Safety Route',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkText,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(onPressed: () { 

              //Implement navigation to Settings 
              SnackBar(content: Text('Settings coming soon!'),);
             }, icon: Icon(Icons.bolt, color: Colors.white, size: 20),),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const RouteVerificationBanner(
                  text: 'You are following a security-verified safety route',
                ),
                const SizedBox(height: 14),
                const Text(
                  'This is a guidance route. Please refer to nearby hallways, room numbers, and signage to connect with the path.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 22),
                ..._steps.map((step) => SafetyRouteStepTile(step: step)),
              ],
            ),
          ),
          const SafetyTimeBar(
            text: 'Estimated time to safety: 10 minutes (approx.)',
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
      ),
    );
  }
}