import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('NBA Super', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
        SizedBox(height: 16),
        _Panel(title: '今日比赛', subtitle: '赛程、比分、实时状态'),
        _Panel(title: 'AI 赛后战报', subtitle: '自动生成关键转折和球员表现'),
        _Panel(title: '热门讨论', subtitle: '围绕比赛和球队的轻社区'),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
