import 'package:flutter/material.dart';
import 'package:campus_compass/screens/map_screen.dart';
import 'package:campus_compass/screens/alerts_screen.dart';
import 'package:campus_compass/screens/profile_screen.dart';
import 'package:campus_compass/screens/report_incident_screen.dart';
import 'package:campus_compass/widgets/bottom_nav_bar.dart';


import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  final int tabIndex;
  final Widget? child;
  const HomeScreen({super.key, this.tabIndex = 0, this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // No local currentIndex: derive active tab from router location.

  final List<Widget> _screens = const [
    MapScreen(),
    ReportIncidentScreen(),
    AlertsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onTabChanged(int index) {
    // Update the URL using go_router
    final tabPaths = ['/home/map', '/home/report', '/home/alerts', '/home/profile'];
    if (index >= 0 && index < tabPaths.length) {
      context.go(tabPaths[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;

    // Use the tabIndex provided by the ShellRoute builder so the shell
    // reliably reflects the router state (works across back navigation).
    int effectiveIndex = widget.tabIndex;

    final body = child ?? IndexedStack(index: effectiveIndex, children: _screens);

    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavBar(
        currentIndex: effectiveIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}
