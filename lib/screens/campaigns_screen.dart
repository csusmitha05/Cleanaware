import 'package:flutter/material.dart';

class CampaignsScreen extends StatelessWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final campaigns = const [
      ('Lakefront Revival', 'Sector 9 Lake', 'Saturday • 7:00 AM', Icons.water_drop_outlined),
      ('No-Plastic Bazaar Drive', 'Central Market', 'Sunday • 9:30 AM', Icons.shopping_bag_outlined),
      ('School Eco Sprint', 'Greenfield High', 'Monday • 8:00 AM', Icons.school_outlined),
      ('Tree Guard Repair', 'Ward 14 Parks', 'Wednesday • 6:30 AM', Icons.park_outlined),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Community Campaigns')),
      body: ListView.builder(
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
                      CircleAvatar(
                        backgroundColor: const Color(0xFFD8EFE5),
                        child: Icon(item.$4, color: const Color(0xFF0F766E)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.$1,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(item.$2, style: const TextStyle(fontSize: 15, color: Color(0xFF41504B))),
                  const SizedBox(height: 4),
                  Text(item.$3, style: const TextStyle(fontSize: 13, color: Color(0xFF5B6A64))),
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
      ),
    );
  }
}
