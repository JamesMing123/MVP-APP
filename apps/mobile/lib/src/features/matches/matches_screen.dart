import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('比赛中心', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            title: const Text('Lakers vs Celtics'),
            subtitle: const Text('LIVE  Q3  78 - 74'),
            trailing: const Icon(Icons.sports_score),
            onTap: () => context.push('/matches/1'),
          ),
        ),
      ],
    );
  }
}
