import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leaders = const [
      ('Aarav Patel', 36, 'Zone 2 Champion'),
      ('Sree Lakshmi', 31, 'Rapid Response Volunteer'),
      ('Maya Reddy', 29, 'Plastic-Free Campaign'),
      ('Rahul Iyer', 24, 'Ward Coordinator'),
      ('Nisha Kumar', 22, 'Awareness Speaker'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Citizen Leaderboard')),
      body: ListView.builder(
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
              title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${item.$2} verified actions • ${item.$3}'),
              trailing: const Icon(Icons.emoji_events_outlined),
            ),
          );
        },
      ),
    );
  }
}
