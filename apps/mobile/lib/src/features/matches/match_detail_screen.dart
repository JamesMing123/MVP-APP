import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MatchDetailScreen extends StatefulWidget {
  const MatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  late final WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8000/ws/v1/matches/${widget.matchId}'),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('比赛详情')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder(
          stream: _channel.stream,
          builder: (context, snapshot) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Match #${widget.matchId}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    title: const Text('实时比分 WebSocket'),
                    subtitle: Text(snapshot.data?.toString() ?? '等待比分更新...'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
