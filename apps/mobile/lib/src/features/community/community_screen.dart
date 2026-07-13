import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'community_model.dart';
import 'community_repository.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(communityPostsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/community/new'),
        icon: const Icon(Icons.edit),
        label: const Text('发帖'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(communityPostsProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '社区',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: '刷新',
                  onPressed: () => ref.invalidate(communityPostsProvider),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 16),
            posts.when(
              data: (items) => items.isEmpty
                  ? const _EmptyPosts()
                  : Column(
                      children: [
                        for (final post in items) _PostCard(post: post),
                      ],
                    ),
              loading: () => const _LoadingPosts(),
              error: (error, _) => _ErrorPosts(
                onRetry: () => ref.invalidate(communityPostsProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends ConsumerStatefulWidget {
  const _PostCard({required this.post});

  final CommunityPost post;

  @override
  ConsumerState<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<_PostCard> {
  late int _likeCount = widget.post.likeCount;
  bool _liked = false;
  bool _isLiking = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final timeText = DateFormat('MM/dd HH:mm').format(post.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text('#${post.userId}')),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.title,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(timeText,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => context.push('/community/posts/${post.id}'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  post.content,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _isLiking || _liked ? null : _like,
                  icon: Icon(_liked ? Icons.favorite : Icons.favorite_border),
                  label: Text('$_likeCount'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.mode_comment_outlined),
                  label: Text('${post.commentCount}'),
                ),
                if (post.matchId != null) ...[
                  const Spacer(),
                  Chip(label: Text('Match #${post.matchId}')),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _like() async {
    setState(() => _isLiking = true);
    try {
      final count =
          await ref.read(communityRepositoryProvider).likePost(widget.post.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _likeCount = count;
        _liked = true;
      });
    } finally {
      if (mounted) {
        setState(() => _isLiking = false);
      }
    }
  }
}

class _LoadingPosts extends StatelessWidget {
  const _LoadingPosts();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyPosts extends StatelessWidget {
  const _EmptyPosts();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(child: Text('还没有帖子，来发第一条讨论吧')),
    );
  }
}

class _ErrorPosts extends StatelessWidget {
  const _ErrorPosts({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          const Text('帖子加载失败，请确认后端服务已启动'),
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
