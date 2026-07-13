import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'match_model.dart';
import 'match_repository.dart';

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final matches = ref.watch(matchesProvider);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(matchesProvider.future),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Expanded(
                  child: Text('比赛中心',
                      style: TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800))),
              IconButton(
                  tooltip: '刷新',
                  onPressed: () => ref.invalidate(matchesProvider),
                  icon: const Icon(Icons.refresh)),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                  value: 0, icon: Icon(Icons.today), label: Text('今日比赛')),
              ButtonSegment(
                  value: 1, icon: Icon(Icons.history), label: Text('历史比赛')),
            ],
            selected: {_tab},
            onSelectionChanged: (value) => setState(() => _tab = value.first),
          ),
          const SizedBox(height: 16),
          matches.when(
            data: (items) {
              final now = DateTime.now();
              final filtered = _tab == 0
                  ? items
                      .where((m) => DateUtils.isSameDay(m.startTime, now))
                      .toList()
                  : items
                      .where((m) => m.startTime
                          .isBefore(DateTime(now.year, now.month, now.day)))
                      .toList();
              return filtered.isEmpty
                  ? _EmptyMatches(
                      text: _tab == 0 ? '暂无今日比赛' : '暂无历史比赛，请先同步更多赛程数据')
                  : Column(children: [
                      for (final match in filtered)
                        _MatchCard(
                            match: match,
                            onTap: () => context.push('/matches/${match.id}'))
                    ]);
            },
            loading: () => const _LoadingMatches(),
            error: (_, __) =>
                _ErrorMatches(onRetry: () => ref.invalidate(matchesProvider)),
          ),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match, required this.onTap});
  final NbaMatch match;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final timeText = DateFormat('MM/dd HH:mm').format(match.startTime);
    final statusText = match.isLive ? 'LIVE' : match.status.toUpperCase();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Text(match.awayTeam.abbreviation)),
        title: Text(match.matchup,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
            '$statusText · $timeText · ${match.period ?? '-'} ${match.clock ?? ''}'),
        trailing: Text(match.scoreText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _LoadingMatches extends StatelessWidget {
  const _LoadingMatches();
  @override
  Widget build(BuildContext context) => const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(child: CircularProgressIndicator()));
}

class _EmptyMatches extends StatelessWidget {
  const _EmptyMatches({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(child: Text(text)));
}

class _ErrorMatches extends StatelessWidget {
  const _ErrorMatches({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          const Text('比赛加载失败，请确认后端服务已启动', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试')),
        ],
      ),
    );
  }
}
