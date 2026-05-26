import 'dart:async';
import 'package:flutter/material.dart';
import '../firebase/firestore_service.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class PostProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<PostModel> _posts = [];
  List<PostModel> _userPosts = [];
  bool _isLoading = false;

  StreamSubscription<List<PostModel>>? _postsSubscription;
  StreamSubscription<List<PostModel>>? _userPostsSubscription;

  List<PostModel> get posts => _posts;
  List<PostModel> get userPosts => _userPosts;
  bool get isLoading => _isLoading;

  PostProvider() {
    _subscribeToPosts();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Subscribe to the real-time stream of all posts to show on the main feed
  void _subscribeToPosts() {
    _postsSubscription?.cancel();
    _postsSubscription = _firestoreService.getPostsStream().listen(
      (updatedPosts) {
        _posts = updatedPosts;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Error loading posts stream: $e');
      },
    );
  }

  // Subscribe to posts written by a specific user (for their profile page)
  void subscribeToUserPosts(String uid) {
    _userPostsSubscription?.cancel();
    _userPostsSubscription = _firestoreService.getUserPostsStream(uid).listen(
      (updatedUserPosts) {
        _userPosts = updatedUserPosts;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Error loading user posts: $e');
      },
    );
  }

  // Create a new text post in Firestore
  Future<void> createPost({
    required String content,
    required UserModel currentUser,
  }) async {
    _setLoading(true);
    try {
      final newPost = PostModel(
        id: '', // Firestore will automatically generate this ID
        authorId: currentUser.uid,
        authorName: currentUser.displayName,
        authorPhotoUrl: currentUser.photoUrl,
        content: content,
        imageUrl: null, // Images are disabled on the free tier
        likes: [],
        commentsCount: 0,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createPost(newPost);
    } finally {
      _setLoading(false);
    }
  }

  // Edit an existing post's text content
  Future<void> editPost({
    required String postId,
    required String content,
    required String userId,
  }) async {
    _setLoading(true);
    try {
      await _firestoreService.updatePost(postId, content: content, imageUrl: null);
    } finally {
      _setLoading(false);
    }
  }

  // Delete a post by ID
  Future<void> deletePost(String postId) async {
    _setLoading(true);
    try {
      await _firestoreService.deletePost(postId);
    } finally {
      _setLoading(false);
    }
  }

  // Like or unlike a post
  Future<void> toggleLike(String postId, String userId, UserModel currentPoster) async {
    try {
      await _firestoreService.toggleLikePost(postId, userId, currentPoster);
    } catch (e) {
      debugPrint('Failed to toggle like: $e');
    }
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    _userPostsSubscription?.cancel();
    super.dispose();
  }
}
