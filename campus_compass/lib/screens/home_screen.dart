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
  late int _currentIndex;

  final List<Widget> _screens = const [
    MapScreen(),
    ReportIncidentScreen(),
    AlertsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.tabIndex;
  }

  void _onTabChanged(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    // Update the URL using go_router
    final tabPaths = ['/home/map', '/home/report', '/home/alerts', '/home/profile'];
    if (index >= 0 && index < tabPaths.length) {
      context.go(tabPaths[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    final body = child ?? IndexedStack(index: _currentIndex, children: _screens);

    // If child is provided by a ShellRoute, derive selected index from location
    int effectiveIndex = _currentIndex;
    try {
      final loc = Uri.base.path;
      if (loc.startsWith('/home/report'))
        effectiveIndex = 1;
      else if (loc.startsWith('/home/alerts'))
        effectiveIndex = 2;
      else if (loc.startsWith('/home/profile'))
        effectiveIndex = 3;
      else if (loc.startsWith('/home/map')) effectiveIndex = 0;
    } catch (_) {}

    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavBar(
        currentIndex: effectiveIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}
