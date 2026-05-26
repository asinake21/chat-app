import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorPhotoUrl;
  final String content;
  final String? imageUrl;
  final List<String> likes; // UIDs of users who liked this post
  final int commentsCount;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorPhotoUrl,
    required this.content,
    this.imageUrl,
    required this.likes,
    required this.commentsCount,
    required this.createdAt,
  });

  /// Factory constructor to map a Firestore document payload to PostModel
  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Anonymous Student',
      authorPhotoUrl: map['authorPhotoUrl'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      likes: List<String>.from(map['likes'] ?? []),
      commentsCount: map['commentsCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts the PostModel details to a Map for Firestore uploading
  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'imageUrl': imageUrl,
      'likes': likes,
      'commentsCount': commentsCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Helper to create a copy of the post with modified fields
  PostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    String? content,
    String? imageUrl,
    List<String>? likes,
    int? commentsCount,
    DateTime? createdAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
