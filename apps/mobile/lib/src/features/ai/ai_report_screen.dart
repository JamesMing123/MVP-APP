import 'package:flutter/material.dart';

class AiReportScreen extends StatelessWidget {
  const AiReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('AI 战报', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        SizedBox(height: 16),
        Card(
          child: ListTile(
            title: Text('赛后战报生成'),
            subtitle: Text('基于比分、球队和技术统计自动生成。'),
          ),
        ),
      ],
    );
  }
}
