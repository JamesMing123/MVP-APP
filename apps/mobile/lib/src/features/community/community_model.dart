class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.likeCount,
    required this.commentCount,
    required this.status,
    required this.createdAt,
    this.matchId,
    this.teamId,
    this.imageUrls,
  });

  final int id;
  final int userId;
  final int? matchId;
  final int? teamId;
  final String title;
  final String content;
  final List<String>? imageUrls;
  final int likeCount;
  final int commentCount;
  final String status;
  final DateTime createdAt;

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      matchId: json['match_id'] as int?,
      teamId: json['team_id'] as int?,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrls: (json['image_urls'] as List<dynamic>?)?.cast<String>(),
      likeCount: json['like_count'] as int,
      commentCount: json['comment_count'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  CommunityPost copyWith({int? likeCount, int? commentCount}) {
    return CommunityPost(
      id: id,
      userId: userId,
      matchId: matchId,
      teamId: teamId,
      title: title,
      content: content,
      imageUrls: imageUrls,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      status: status,
      createdAt: createdAt,
    );
  }
}

class CommunityComment {
  const CommunityComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.likeCount,
    required this.status,
    required this.createdAt,
    this.parentId,
  });

  final int id;
  final int postId;
  final int userId;
  final int? parentId;
  final String content;
  final int likeCount;
  final String status;
  final DateTime createdAt;

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      userId: json['user_id'] as int,
      parentId: json['parent_id'] as int?,
      content: json['content'] as String,
      likeCount: json['like_count'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}
