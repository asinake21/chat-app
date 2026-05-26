import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String bio;
  final DateTime joinedAt;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.bio,
    required this.joinedAt,
    this.fcmToken,
  });

  /// Factory constructor to create a UserModel from a Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      bio: map['bio'] ?? '',
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fcmToken: map['fcmToken'],
    );
  }

  /// Converts the UserModel into a Map structure for Firestore writes
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'joinedAt': Timestamp.fromDate(joinedAt),
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  /// Helper to create a copy of the user with modified fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? bio,
    DateTime? joinedAt,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      joinedAt: joinedAt ?? this.joinedAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
