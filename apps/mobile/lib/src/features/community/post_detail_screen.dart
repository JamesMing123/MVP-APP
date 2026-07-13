import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'community_model.dart';
import 'community_repository.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  const PostDetailScreen({super.key, required this.postId});

  final int postId;

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = ref.watch(communityPostProvider(widget.postId));
    final comments = ref.watch(postCommentsProvider(widget.postId));

    return Scaffold(
      appBar: AppBar(title: const Text('帖子详情')),
      body: post.when(
        data: (item) => Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(communityPostProvider(widget.postId));
                  ref.invalidate(postCommentsProvider(widget.postId));
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _PostBody(post: item),
                    const SizedBox(height: 16),
                    Text('评论', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    comments.when(
                      data: (items) => items.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(child: Text('暂无评论，来抢第一条')),
                            )
                          : Column(children: [
                              for (final comment in items)
                                _CommentTile(comment: comment)
                            ]),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, __) => const Text('评论加载失败'),
                    ),
                  ],
                ),
              ),
            ),
            _CommentInput(
              controller: _commentController,
              isSubmitting: _isSubmitting,
              onSubmit: _submitComment,
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('帖子加载失败')),
      ),
    );
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(communityRepositoryProvider)
          .createComment(postId: widget.postId, content: content);
      _commentController.clear();
      ref.invalidate(postCommentsProvider(widget.postId));
      ref.invalidate(communityPostProvider(widget.postId));
      ref.invalidate(communityPostsProvider);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _PostBody extends StatelessWidget {
  const _PostBody({required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(DateFormat('yyyy/MM/dd HH:mm').format(post.createdAt)),
            const SizedBox(height: 16),
            Text(post.content),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final CommunityComment comment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('#${comment.userId}')),
        title: Text(comment.content),
        subtitle: Text(DateFormat('MM/dd HH:mm').format(comment.createdAt)),
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  const _CommentInput(
      {required this.controller,
      required this.isSubmitting,
      required this.onSubmit});

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(hintText: '写评论...'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: isSubmitting ? null : onSubmit,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
