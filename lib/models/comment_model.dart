import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorPhotoUrl;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorPhotoUrl,
    required this.content,
    required this.createdAt,
  });

  /// Factory constructor to convert Firestore maps to CommentModel
  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      id: id,
      postId: map['postId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Anonymous Student',
      authorPhotoUrl: map['authorPhotoUrl'] ?? '',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts the CommentModel into a Map structure for Firestore database
  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
