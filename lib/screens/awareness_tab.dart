import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/tip_model.dart';
import '../services/tts_service.dart';

class AwarenessTab extends StatefulWidget {
  const AwarenessTab({super.key});

  @override
  State<AwarenessTab> createState() => _AwarenessTabState();
}

class _AwarenessTabState extends State<AwarenessTab> {
  final TtsService _tts = TtsService();
  late Future<List<TipModel>> _tipsFuture;
  static final List<TipModel> _fallbackTips = [
    TipModel(
      title: 'Segregate Waste Daily',
      description:
          'Use separate wet and dry bins at home to improve recycling and reduce landfill load.',
      image: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b',
    ),
    TipModel(
      title: 'Carry Reusable Bottles',
      description:
          'Avoid single-use plastic bottles by carrying a reusable steel or BPA-free bottle.',
      image: 'https://images.unsplash.com/photo-1523362628745-0c100150b504',
    ),
    TipModel(
      title: 'Report Civic Issues Quickly',
      description:
          'Capture photo and exact location for faster municipal response and issue closure.',
      image: 'https://images.unsplash.com/photo-1604187351574-c75ca79f5807',
    ),
    TipModel(
      title: 'Choose Public Transport',
      description:
          'Use bus, metro, or carpool 2-3 days a week to reduce traffic and carbon emissions.',
      image: 'https://images.unsplash.com/photo-1519003722824-194d4455a60c',
    ),
    TipModel(
      title: 'Save Water at Home',
      description:
          'Fix leaks, close taps while brushing, and reuse RO reject water for cleaning.',
      image: 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tipsFuture = _loadTips();
  }

  Future<List<TipModel>> _loadTips() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/tips.json');
      final List<dynamic> data = json.decode(jsonStr);
      final tips =
          data.map((e) => TipModel.fromMap(e as Map<String, dynamic>)).toList();
      if (tips.isEmpty) return _fallbackTips;
      return tips;
    } catch (_) {
      return _fallbackTips;
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TipModel>>(
      future: _tipsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tips = snapshot.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: tips.length,
          itemBuilder: (context, index) {
            final tip = tips[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Stack(
                      children: [
                        Image.network(
                          tip.image,
                          height: 190,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          left: 12,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.44),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text('Action Tip',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tip.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 6),
                        Text(tip.description,
                            style: const TextStyle(fontSize: 15)),
                        const SizedBox(height: 9),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _tts.speak('${tip.title}. ${tip.description}'),
                          icon: const Icon(Icons.volume_up_outlined),
                          label: const Text('Read Aloud'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
