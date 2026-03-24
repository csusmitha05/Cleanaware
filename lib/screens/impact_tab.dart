import 'package:flutter/material.dart';

import '../models/issue_model.dart';
import '../services/firestore_service.dart';

class ImpactTab extends StatelessWidget {
  const ImpactTab({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return StreamBuilder<List<IssueModel>>(
      stream: firestore.getAllIssues(),
      builder: (context, snapshot) {
        final issues = snapshot.data ?? const <IssueModel>[];
        final total = issues.length;
        final resolved = issues.where((e) => e.status.toLowerCase() == 'resolved').length;
        final pending = total - resolved;
        final resolvedPct = total == 0 ? 0 : ((resolved / total) * 100).round();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _hero(total: total, resolvedPct: resolvedPct),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _metric('Total', '$total', Icons.analytics_outlined)),
                const SizedBox(width: 10),
                Expanded(child: _metric('Resolved', '$resolved', Icons.task_alt_outlined)),
                const SizedBox(width: 10),
                Expanded(child: _metric('Pending', '$pending', Icons.pending_actions_outlined)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Resolution Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            _progressRow('Resolved', resolved, total, const Color(0xFF16A34A)),
            const SizedBox(height: 8),
            _progressRow('Pending', pending, total, const Color(0xFFFB923C)),
            const SizedBox(height: 16),
            const Text('Project Scale Highlights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Multi-module architecture', style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 6),
                    Text('Auth, issue reporting, awareness feed, notifications, admin workflows, analytics tab.'),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _hero({required int total, required int resolvedPct}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F766E), Color(0xFF0284C7)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Impact Dashboard', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            '$total community reports tracked with $resolvedPct% closure efficiency.',
            style: const TextStyle(color: Color(0xFFE7FBFF)),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD5E8E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0F766E)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          Text(label),
        ],
      ),
    );
  }

  Widget _progressRow(String label, int value, int total, Color color) {
    final ratio = total == 0 ? 0.0 : value / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('$value'),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 9,
            backgroundColor: const Color(0xFFE4EFEA),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
