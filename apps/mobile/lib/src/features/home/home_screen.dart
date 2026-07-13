import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).state.user;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NBA Super',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w800)),
                    if (user != null)
                      Text('Hi, ${user.nickname}',
                          style: Theme.of(context).textTheme.bodyMedium),
                  ]),
            ),
            IconButton(
                tooltip: '退出登录',
                onPressed: () => ref.read(authControllerProvider).logout(),
                icon: const Icon(Icons.logout)),
          ],
        ),
        const SizedBox(height: 16),
        _Panel(
            title: '今日比赛',
            subtitle: '赛程、比分、实时状态',
            icon: Icons.sports_basketball,
            onTap: () => context.go('/matches')),
        _Panel(
            title: 'AI 赛后战报',
            subtitle: '自动生成关键转折和球员表现',
            icon: Icons.auto_awesome,
            onTap: () => context.go('/ai')),
        _Panel(
            title: '热门讨论',
            subtitle: '围绕比赛和球队的轻社区',
            icon: Icons.forum,
            onTap: () => context.go('/community')),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.onTap});
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
