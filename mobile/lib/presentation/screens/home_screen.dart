import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/incident_providers.dart';
import '../widgets/status_banner.dart';
import '../widgets/incident_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(activeIncidentsProvider);
    final campusStatus = ref.watch(campusStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Compass'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          StatusBanner(status: campusStatus),
          Expanded(
            child: statusAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    const Text('Could not load incidents.'),
                    TextButton(
                      onPressed: () => ref.invalidate(activeIncidentsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (incidents) => incidents.isEmpty
                  ? const _NormalStateBody()
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: incidents.length,
                      itemBuilder: (ctx, i) => IncidentCard(incident: incidents[i]),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(currentIndex: 0),
    );
  }
}

class _NormalStateBody extends StatelessWidget {
  const _NormalStateBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade600),
          const SizedBox(height: 12),
          const Text('All clear — no active emergencies.',
              style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex});
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            context.go('/home');
          case 1:
            context.go('/map');
          case 2:
            context.go('/route');
          case 3:
            context.go('/resources');
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Map'),
        NavigationDestination(icon: Icon(Icons.directions_outlined), label: 'Route'),
        NavigationDestination(icon: Icon(Icons.contacts_outlined), label: 'Resources'),
      ],
    );
  }
}
