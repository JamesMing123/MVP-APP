import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'community_repository.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('发布讨论')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              maxLength: 180,
              decoration: const InputDecoration(
                labelText: '标题',
                hintText: '例如：今天湖人末节怎么打？',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) =>
                  value != null && value.trim().isNotEmpty ? null : '请输入标题',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contentController,
              minLines: 8,
              maxLines: 14,
              maxLength: 5000,
              decoration: const InputDecoration(
                labelText: '正文',
                hintText: '说说你的看法...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 168),
                  child: Icon(Icons.notes),
                ),
              ),
              validator: (value) =>
                  value != null && value.trim().isNotEmpty ? null : '请输入正文',
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send),
              label: Text(_isSubmitting ? '发布中...' : '发布'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await ref.read(communityRepositoryProvider).createPost(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
          );
      ref.invalidate(communityPostsProvider);
      if (mounted) {
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = '发布失败，请稍后再试');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
