import 'package:flutter/material.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  static const _contacts = [
    _Contact('Concordia Security', '514-848-3717', Icons.security),
    _Contact('Campus Emergency', '911', Icons.emergency),
    _Contact('Student Wellness', '514-848-2424', Icons.health_and_safety),
    _Contact('ITServices Help', '514-848-2424', Icons.support_agent),
  ];

  static const _guides = [
    _Guide('Evacuation Procedures', Icons.exit_to_app),
    _Guide('Fire Emergency', Icons.local_fire_department),
    _Guide('Medical Emergency', Icons.medical_services),
    _Guide('Lockdown Procedures', Icons.lock),
    _Guide('Accessibility Assistance', Icons.accessible),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resources')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _SectionHeader(label: 'Emergency Contacts'),
          ..._contacts.map((c) => _ContactTile(contact: c)),
          const SizedBox(height: 8),
          _SectionHeader(label: 'Safety Guides'),
          ..._guides.map((g) => _GuideTile(guide: g)),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

class _Contact {
  const _Contact(this.name, this.phone, this.icon);
  final String name;
  final String phone;
  final IconData icon;
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.contact});
  final _Contact contact;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(contact.icon, color: Colors.red),
        title: Text(contact.name),
        subtitle: Text(contact.phone),
        trailing: IconButton(
          icon: const Icon(Icons.phone),
          onPressed: () {/* TODO: launch dialer */},
        ),
      ),
    );
  }
}

class _Guide {
  const _Guide(this.title, this.icon);
  final String title;
  final IconData icon;
}

class _GuideTile extends StatelessWidget {
  const _GuideTile({required this.guide});
  final _Guide guide;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(guide.icon),
      title: Text(guide.title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {/* TODO: open guide detail */},
    );
  }
}
