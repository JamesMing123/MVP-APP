import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('社区', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        SizedBox(height: 16),
        Card(
          child: ListTile(
            title: Text('今晚湖凯大战怎么看？'),
            subtitle: Text('24 评论 · 128 赞'),
          ),
        ),
      ],
    );
  }
}
