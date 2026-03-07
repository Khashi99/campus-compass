import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _alertsEnabled = true;
  bool _accessibleRoutes = false;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader(label: 'Notifications'),
          SwitchListTile(
            title: const Text('Emergency Alerts'),
            subtitle: const Text('Receive push notifications for active incidents'),
            value: _alertsEnabled,
            onChanged: (v) => setState(() => _alertsEnabled = v),
          ),
          const Divider(),
          const _SectionHeader(label: 'Accessibility'),
          SwitchListTile(
            title: const Text('Accessible Routes Only'),
            subtitle: const Text('Restrict navigation to wheelchair-accessible paths'),
            value: _accessibleRoutes,
            onChanged: (v) => setState(() => _accessibleRoutes = v),
          ),
          const Divider(),
          const _SectionHeader(label: 'Language'),
          ListTile(
            title: const Text('App Language'),
            subtitle: Text(_language),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final picked = await showDialog<String>(
                context: context,
                builder: (_) => SimpleDialog(
                  title: const Text('Select Language'),
                  children: ['English', 'Français']
                      .map((l) => SimpleDialogOption(
                            child: Text(l),
                            onPressed: () => Navigator.pop(context, l),
                          ))
                      .toList(),
                ),
              );
              if (picked != null) setState(() => _language = picked);
            },
          ),
          const Divider(),
          const _SectionHeader(label: 'Offline Cache'),
          ListTile(
            title: const Text('Refresh Offline Map Data'),
            leading: const Icon(Icons.download_outlined),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Offline data refreshed.')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(label,
          style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold)),
    );
  }
}
