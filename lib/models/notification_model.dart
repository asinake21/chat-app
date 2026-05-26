import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String receiverId;
  final String senderId;
  final String senderName;
  final String senderPhotoUrl;
  final String type; // 'like' or 'comment'
  final String postId;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.receiverId,
    required this.senderId,
    required this.senderName,
    required this.senderPhotoUrl,
    required this.type,
    required this.postId,
    required this.createdAt,
    required this.isRead,
  });

  /// Factory constructor to convert Firestore maps to NotificationModel
  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      receiverId: map['receiverId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'Someone',
      senderPhotoUrl: map['senderPhotoUrl'] ?? '',
      type: map['type'] ?? 'like',
      postId: map['postId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  /// Converts the NotificationModel into a Map structure for Firestore database
  Map<String, dynamic> toMap() {
    return {
      'receiverId': receiverId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'type': type,
      'postId': postId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  /// Helper to create a copy of the notification with modified fields
  NotificationModel copyWith({
    String? id,
    String? receiverId,
    String? senderId,
    String? senderName,
    String? senderPhotoUrl,
    String? type,
    String? postId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      receiverId: receiverId ?? this.receiverId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      type: type ?? this.type,
      postId: postId ?? this.postId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
