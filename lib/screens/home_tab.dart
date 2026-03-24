import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

class HomeTab extends StatelessWidget {
  final String userName;
  final VoidCallback onGoReportIssue;

  HomeTab({super.key, required this.userName, required this.onGoReportIssue});

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F766E), Color(0xFF16A34A)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $userName',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Neighborhood mission: cleaner streets, faster reporting, stronger participation.',
                  style: TextStyle(color: Color(0xFFE5FFF4), fontSize: 14),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F766E),
                  ),
                  onPressed: onGoReportIssue,
                  icon: const Icon(Icons.campaign_outlined),
                  label: const Text('Report New Issue'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<int>(
            future: _firestoreService.getTotalIssuesCount(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Row(
                children: [
                  Expanded(
                    child: _kpiCard(
                      context,
                      title: 'Total Reports',
                      value: '$count',
                      icon: Icons.report_gmailerrorred_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _kpiCard(
                      context,
                      title: 'Active Volunteers',
                      value: count == 0 ? '0' : '${count * 3 + 12}',
                      icon: Icons.groups_2_outlined,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Text('Mission Control', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.map_outlined,
            title: 'Live Community Campaigns',
            subtitle: 'City drives, school programs, and ward-level events.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CampaignsScreen()),
              );
            },
          ),
          _ActionTile(
            icon: Icons.emoji_events_outlined,
            title: 'Citizen Leaderboard',
            subtitle: 'Top contributors and clean-zone champions.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              );
            },
          ),
          _ActionTile(
            icon: Icons.security_outlined,
            title: 'Rapid Response Flow',
            subtitle: 'Photo + location + verification for faster municipal action.',
            onTap: onGoReportIssue,
          ),
        ],
      ),
    );
  }

  Widget _kpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD3E6DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0F766E)),
          const SizedBox(height: 10),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: Color(0xFF4C5B55))),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFD8EFE5),
          child: Icon(icon, color: const Color(0xFF0F766E)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }
}

class CampaignsScreen extends StatelessWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Community Campaigns')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestore.watchEvents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final campaigns = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              final item = campaigns[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFFD8EFE5),
                            child: Icon(Icons.event_note, color: Color(0xFF0F766E)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item['title']?.toString() ?? 'Campaign',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['location']?.toString() ?? 'Location TBD',
                        style: const TextStyle(fontSize: 15, color: Color(0xFF41504B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Volunteers: ${item['volunteers'] ?? 0}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF5B6A64)),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.volunteer_activism_outlined),
                        label: const Text('Join Campaign'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Citizen Leaderboard')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestore.watchLeadership(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final leaders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: leaders.length,
            itemBuilder: (context, index) {
              final item = leaders[index];
              final rank = index + 1;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: rank <= 3 ? const Color(0xFFFFE5A5) : const Color(0xFFD8EFE5),
                    child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  title: Text(
                    item['name']?.toString() ?? 'Citizen',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('${item['score'] ?? 0} points - ${item['badge'] ?? 'Volunteer'}'),
                  trailing: const Icon(Icons.emoji_events_outlined),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
