import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // USER PROFILE METHODS
  // ==========================================

  // Saves a new user's profile information to the users collection
  Future<void> createUser(UserModel user) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap());
  }

  // Helper to fetch a user profile from Firestore using their unique ID
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Updates profile info. If displayName or photoUrl changes, we also update
  // the copies stored in their posts so they don't show old info.
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

      // If user changed their name or photo, update all their posts as well
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
  // POST METHODS
  // ==========================================

  // Adds a new post to the database
  Future<void> createPost(PostModel post) async {
    await _db.collection(AppConstants.postsCollection).add(post.toMap());
  }

  // Updates the post content or its image URL
  Future<void> updatePost(String postId, {required String content, String? imageUrl}) async {
    final Map<String, dynamic> data = {'content': content};
    if (imageUrl != null) data['imageUrl'] = imageUrl;

    await _db.collection(AppConstants.postsCollection).doc(postId).update(data);
  }

  // Deletes a post and uses a batch to delete all comments associated with it
  Future<void> deletePost(String postId) async {
    final postRef = _db.collection(AppConstants.postsCollection).doc(postId);

    final batch = _db.batch();
    batch.delete(postRef);

    // Find and delete all comments on this post too
    final commentsQuery = await _db
        .collection(AppConstants.commentsCollection)
        .where('postId', isEqualTo: postId)
        .get();

    for (var doc in commentsQuery.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Streams all posts sorted by creation date (newest first) for the main feed
  // TODO: Add pagination later if we start having too many posts
  Stream<List<PostModel>> getPostsStream() {
    return _db
        .collection(AppConstants.postsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Streams posts written by a specific user (for their profile page)
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

  // Likes or unlikes a post. Also sends a notification if someone else liked your post.
  Future<void> toggleLikePost(String postId, String userId, UserModel currentPoster) async {
    final postRef = _db.collection(AppConstants.postsCollection).doc(postId);
    final postDoc = await postRef.get();

    if (!postDoc.exists) return;

    final post = PostModel.fromMap(postDoc.data()!, postDoc.id);
    final isLiked = post.likes.contains(userId);

    if (isLiked) {
      // Unlike the post
      await postRef.update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } else {
      // Like the post
      await postRef.update({
        'likes': FieldValue.arrayUnion([userId])
      });

      // Notify the post owner (only if it's someone else liking it)
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
  // COMMENT METHODS
  // ==========================================

  // Saves a comment and increments the commentsCount on the post document
  Future<void> addComment(CommentModel comment, String postAuthorId, UserModel currentPoster) async {
    final batch = _db.batch();

    // 1. Create the comment document
    final commentRef = _db.collection(AppConstants.commentsCollection).doc();
    batch.set(commentRef, comment.toMap());

    // 2. Increment the comment counter on the main post
    final postRef = _db.collection(AppConstants.postsCollection).doc(comment.postId);
    batch.update(postRef, {'commentsCount': FieldValue.increment(1)});

    await batch.commit();

    // 3. Notify the post author about the comment
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

  // Streams all comments on a post, sorted by oldest first (chronological order)
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
  // NOTIFICATION METHODS
  // ==========================================

  // Saves a new activity notification
  Future<void> createNotification(NotificationModel notification) async {
    await _db
        .collection(AppConstants.notificationsCollection)
        .add(notification.toMap());
  }

  // Streams notifications received by a user, newest first
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

  // Marks a notification as read when user views their notifications screen
  Future<void> markNotificationAsRead(String notificationId) async {
    await _db
        .collection(AppConstants.notificationsCollection)
        .doc(notificationId)
        .update({'isRead': true});
  }
}
