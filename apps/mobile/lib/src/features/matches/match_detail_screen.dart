import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'match_model.dart';
import 'match_repository.dart';

const wsBaseUrl = String.fromEnvironment(
  'WS_BASE_URL',
  defaultValue: 'ws://localhost:8000/ws/v1',
);

class MatchDetailScreen extends ConsumerStatefulWidget {
  const MatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  WebSocketChannel? _channel;
  NbaMatch? _liveMatch;
  String? _socketStatus;

  int get _matchId => int.parse(widget.matchId);

  @override
  void initState() {
    super.initState();
    _connectLiveScore();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchAsync = ref.watch(matchProvider(_matchId));

    return Scaffold(
      appBar: AppBar(title: const Text('比赛详情')),
      body: matchAsync.when(
        data: (match) {
          final displayMatch = _liveMatch ?? match;
          return RefreshIndicator(
            onRefresh: () => ref.refresh(matchProvider(_matchId).future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ScoreHeader(match: displayMatch),
                const SizedBox(height: 12),
                _TeamScoreRows(match: displayMatch),
                const SizedBox(height: 12),
                _LiveScoreCard(socketStatus: _socketStatus),
                const SizedBox(height: 12),
                _DiscussionEntry(matchId: displayMatch.id),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _DetailError(
          onRetry: () => ref.invalidate(matchProvider(_matchId)),
        ),
      ),
    );
  }

  void _connectLiveScore() {
    final channel = WebSocketChannel.connect(
        Uri.parse('$wsBaseUrl/matches/${widget.matchId}'));
    _channel = channel;
    setState(() => _socketStatus = '正在连接实时比分...');

    channel.stream.listen(
      (event) {
        final decoded = jsonDecode(event as String) as Map<String, dynamic>;
        if (decoded['type'] == 'connected') {
          setState(() => _socketStatus = '实时比分已连接');
          return;
        }

        if (decoded['type'] == 'match_score_update') {
          final payload = decoded['payload'] as Map<String, dynamic>;
          setState(() {
            _liveMatch =
                (_liveMatch ?? ref.read(matchProvider(_matchId)).valueOrNull)
                    ?.copyWithLiveScore(payload);
            _socketStatus = '实时比分已更新';
          });
        }
      },
      onError: (_) => setState(() => _socketStatus = '实时比分连接异常'),
      onDone: () => setState(() => _socketStatus = '实时比分连接已断开'),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({required this.match});

  final NbaMatch match;

  @override
  Widget build(BuildContext context) {
    final timeText = DateFormat('yyyy/MM/dd HH:mm').format(match.startTime);
    final statusText = match.isLive ? 'LIVE' : match.status.toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(match.matchup,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('$statusText · $timeText'),
            const SizedBox(height: 16),
            Text(match.scoreText,
                style:
                    const TextStyle(fontSize: 44, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('${match.period ?? '-'} ${match.clock ?? ''}'),
          ],
        ),
      ),
    );
  }
}

class _TeamScoreRows extends StatelessWidget {
  const _TeamScoreRows({required this.match});

  final NbaMatch match;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _TeamScoreRow(team: match.awayTeam, score: match.awayScore),
          const Divider(height: 1),
          _TeamScoreRow(team: match.homeTeam, score: match.homeScore),
        ],
      ),
    );
  }
}

class _TeamScoreRow extends StatelessWidget {
  const _TeamScoreRow({required this.team, required this.score});

  final NbaTeam team;
  final int score;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(team.abbreviation)),
      title:
          Text(team.name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle:
          Text([team.city, team.conference].whereType<String>().join(' · ')),
      trailing: Text('$score',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
    );
  }
}

class _LiveScoreCard extends StatelessWidget {
  const _LiveScoreCard({required this.socketStatus});

  final String? socketStatus;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.sensors),
        title: const Text('实时比分 WebSocket'),
        subtitle: Text(socketStatus ?? '等待实时比分连接...'),
      ),
    );
  }
}

class _DiscussionEntry extends StatelessWidget {
  const _DiscussionEntry({required this.matchId});

  final int matchId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.forum_outlined),
        title: const Text('比赛讨论区'),
        subtitle: Text('查看 Match #$matchId 的球迷讨论'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('比赛详情加载失败'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }
}
