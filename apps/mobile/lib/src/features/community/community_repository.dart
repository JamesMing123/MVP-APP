import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/api_client.dart';
import 'community_model.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository(ref.watch(apiClientProvider));
});

final communityPostsProvider = FutureProvider<List<CommunityPost>>((ref) {
  return ref.watch(communityRepositoryProvider).listPosts();
});

final communityPostProvider =
    FutureProvider.family<CommunityPost, int>((ref, postId) {
  return ref.watch(communityRepositoryProvider).getPost(postId);
});

final postCommentsProvider =
    FutureProvider.family<List<CommunityComment>, int>((ref, postId) {
  return ref.watch(communityRepositoryProvider).listComments(postId);
});

class CommunityRepository {
  CommunityRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CommunityPost>> listPosts({int? matchId, int? teamId}) async {
    final response = await _apiClient.dio.get(
      '/community/posts',
      queryParameters: {
        if (matchId != null) 'match_id': matchId,
        if (teamId != null) 'team_id': teamId,
      },
    );
    final data = _apiClient.unwrap<List<dynamic>>(response);
    return data
        .cast<Map<String, dynamic>>()
        .map(CommunityPost.fromJson)
        .toList(growable: false);
  }

  Future<CommunityPost> createPost({
    required String title,
    required String content,
    int? matchId,
    int? teamId,
  }) async {
    final response = await _apiClient.dio.post(
      '/community/posts',
      data: {
        'title': title,
        'content': content,
        if (matchId != null) 'match_id': matchId,
        if (teamId != null) 'team_id': teamId,
      },
    );
    final data = _apiClient.unwrap<Map<String, dynamic>>(response);
    return CommunityPost.fromJson(data);
  }

  Future<CommunityPost> getPost(int postId) async {
    final response = await _apiClient.dio.get('/community/posts/$postId');
    final data = _apiClient.unwrap<Map<String, dynamic>>(response);
    return CommunityPost.fromJson(data);
  }

  Future<List<CommunityComment>> listComments(int postId) async {
    final response =
        await _apiClient.dio.get('/community/posts/$postId/comments');
    final data = _apiClient.unwrap<List<dynamic>>(response);
    return data
        .cast<Map<String, dynamic>>()
        .map(CommunityComment.fromJson)
        .toList(growable: false);
  }

  Future<CommunityComment> createComment({
    required int postId,
    required String content,
  }) async {
    final response = await _apiClient.dio.post(
      '/community/posts/$postId/comments',
      data: {'content': content},
    );
    final data = _apiClient.unwrap<Map<String, dynamic>>(response);
    return CommunityComment.fromJson(data);
  }

  Future<int> likePost(int postId) async {
    final response = await _apiClient.dio.post('/community/posts/$postId/like');
    final data = _apiClient.unwrap<Map<String, dynamic>>(response);
    return data['like_count'] as int;
  }
}
