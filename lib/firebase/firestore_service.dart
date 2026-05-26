import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // USER OPERATIONS
  // ==========================================

  /// Save new user profile to Firestore
  Future<void> createUser(UserModel user) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap());
  }

  /// Fetch user profile details
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  /// Update user profile details
  Future<void> updateUserProfile(
    String uid, {
    String? displayName,
    String? photoUrl,
    String? bio,
    String? fcmToken,
  }) async {
    final Map<String, dynamic> data = {};
    if (displayName != null) data['displayName'] = displayName;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (bio != null) data['bio'] = bio;
    if (fcmToken != null) data['fcmToken'] = fcmToken;

    if (data.isNotEmpty) {
      await _db.collection(AppConstants.usersCollection).doc(uid).update(data);

      // Denormalize author information in posts where this user is the author
      if (displayName != null || photoUrl != null) {
        final postsQuery = await _db
            .collection(AppConstants.postsCollection)
            .where('authorId', isEqualTo: uid)
            .get();

        final batch = _db.batch();
        for (var doc in postsQuery.docs) {
          final Map<String, dynamic> postUpdate = {};
          if (displayName != null) postUpdate['authorName'] = displayName;
          if (photoUrl != null) postUpdate['authorPhotoUrl'] = photoUrl;
          batch.update(doc.reference, postUpdate);
        }
        await batch.commit();
      }
    }
  }

  // ==========================================
  // POST OPERATIONS
  // ==========================================

  /// Create a new post
  Future<void> createPost(PostModel post) async {
    await _db.collection(AppConstants.postsCollection).add(post.toMap());
  }

  /// Update a post content or image
  Future<void> updatePost(String postId, {required String content, String? imageUrl}) async {
    final Map<String, dynamic> data = {'content': content};
    if (imageUrl != null) data['imageUrl'] = imageUrl;

    await _db.collection(AppConstants.postsCollection).doc(postId).update(data);
  }

  /// Delete a post, its comments and image references
  Future<void> deletePost(String postId) async {
    final postRef = _db.collection(AppConstants.postsCollection).doc(postId);

    // Run in batch to clean up associated comments
    final batch = _db.batch();
    batch.delete(postRef);

    final commentsQuery = await _db
        .collection(AppConstants.commentsCollection)
        .where('postId', isEqualTo: postId)
        .get();

    for (var doc in commentsQuery.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Get stream of all posts, ordered by creation date
  Stream<List<PostModel>> getPostsStream() {
    return _db
        .collection(AppConstants.postsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get stream of posts created by a specific user
  Stream<List<PostModel>> getUserPostsStream(String uid) {
    return _db
        .collection(AppConstants.postsCollection)
        .where('authorId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data(), doc.id))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  /// Toggle post likes (Add or Remove user ID from likes list)
  Future<void> toggleLikePost(String postId, String userId, UserModel currentPoster) async {
    final postRef = _db.collection(AppConstants.postsCollection).doc(postId);
    final postDoc = await postRef.get();

    if (!postDoc.exists) return;

    final post = PostModel.fromMap(postDoc.data()!, postDoc.id);
    final isLiked = post.likes.contains(userId);

    if (isLiked) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([userId])
      });

      // Send activity notification if it's not the user liking their own post
      if (post.authorId != userId) {
        final notif = NotificationModel(
          id: '',
          receiverId: post.authorId,
          senderId: userId,
          senderName: currentPoster.displayName,
          senderPhotoUrl: currentPoster.photoUrl,
          type: 'like',
          postId: postId,
          createdAt: DateTime.now(),
          isRead: false,
        );
        await createNotification(notif);
      }
    }
  }

  // ==========================================
  // COMMENT OPERATIONS
  // ==========================================

  /// Add a comment to a post and update comment count atomically
  Future<void> addComment(CommentModel comment, String postAuthorId, UserModel currentPoster) async {
    final batch = _db.batch();

    // 1. Add comment to subcollection/collection
    final commentRef = _db.collection(AppConstants.commentsCollection).doc();
    batch.set(commentRef, comment.toMap());

    // 2. Increment comment counter in Post document
    final postRef = _db.collection(AppConstants.postsCollection).doc(comment.postId);
    batch.update(postRef, {'commentsCount': FieldValue.increment(1)});

    await batch.commit();

    // 3. Create activity notification (excluding self-comments)
    if (postAuthorId != comment.authorId) {
      final notif = NotificationModel(
        id: '',
        receiverId: postAuthorId,
        senderId: comment.authorId,
        senderName: currentPoster.displayName,
        senderPhotoUrl: currentPoster.photoUrl,
        type: 'comment',
        postId: comment.postId,
        createdAt: DateTime.now(),
        isRead: false,
      );
      await createNotification(notif);
    }
  }

  /// Get stream of comments for a specific post
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _db
        .collection(AppConstants.commentsCollection)
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt)));
  }

  // ==========================================
  // NOTIFICATION OPERATIONS
  // ==========================================

  /// Save notification document to Firestore
  Future<void> createNotification(NotificationModel notification) async {
    await _db
        .collection(AppConstants.notificationsCollection)
        .add(notification.toMap());
  }

  /// Get stream of active notifications for a user
  Stream<List<NotificationModel>> getNotificationsStream(String receiverId) {
    return _db
        .collection(AppConstants.notificationsCollection)
        .where('receiverId', isEqualTo: receiverId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  /// Mark single notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _db
        .collection(AppConstants.notificationsCollection)
        .doc(notificationId)
        .update({'isRead': true});
  }
}
