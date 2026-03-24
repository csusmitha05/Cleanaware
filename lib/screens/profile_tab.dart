import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'admin_issues_screen.dart';

class ProfileTab extends StatelessWidget {
  final String userId;
  final String email;

  ProfileTab({super.key, required this.userId, required this.email});

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final isAdmin = email.toLowerCase().contains('admin');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _profileHeader(email: email),
        const SizedBox(height: 14),
        StreamBuilder(
          stream: _firestoreService.getIssuesByUser(userId),
          builder: (context, snapshot) {
            final issues = snapshot.data ?? const [];
            final total = issues.length;
            final resolved = issues
                .where((issue) => issue.status.toLowerCase() == 'resolved')
                .length;
            final pending = total - resolved;

            return _statsSection(
                total: total, resolved: resolved, pending: pending);
          },
        ),
        const SizedBox(height: 14),
        if (isAdmin)
          Card(
            child: ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text('Admin Issue Center'),
              subtitle: const Text('Review and resolve submitted reports.'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminIssuesScreen()),
                );
              },
            ),
          ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => context.read<AuthService>().logout(),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }

  Widget _profileHeader({required String email}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 27,
            backgroundColor: Color(0xFFD9FFF6),
            child: Icon(Icons.person, color: Color(0xFF0F766E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Community Member',
                    style: TextStyle(color: Color(0xFFD8FFF8))),
                Text(
                  email,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsSection(
      {required int total, required int resolved, required int pending}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        if (isWide) {
          return Row(
            children: [
              Expanded(
                  child: _statCard(
                      icon: Icons.bar_chart, value: total, label: 'Total')),
              const SizedBox(width: 12),
              Expanded(
                  child: _statCard(
                      icon: Icons.check_circle_outline,
                      value: resolved,
                      label: 'Resolved')),
              const SizedBox(width: 12),
              Expanded(
                  child: _statCard(
                      icon: Icons.pending_actions_outlined,
                      value: pending,
                      label: 'Pending')),
            ],
          );
        }

        return Column(
          children: [
            _statCard(icon: Icons.bar_chart, value: total, label: 'Total'),
            const SizedBox(height: 12),
            _statCard(
                icon: Icons.check_circle_outline,
                value: resolved,
                label: 'Resolved'),
            const SizedBox(height: 12),
            _statCard(
                icon: Icons.pending_actions_outlined,
                value: pending,
                label: 'Pending'),
          ],
        );
      },
    );
  }

  Widget _statCard(
      {required IconData icon, required int value, required String label}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD3E6DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0F766E), size: 28),
          const SizedBox(height: 14),
          Text(
            '$value',
            style: const TextStyle(
                fontSize: 44, fontWeight: FontWeight.w700, height: 1),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 32 * 0.65)),
        ],
      ),
    );
  }
}
