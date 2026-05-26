import 'dart:async';
import 'package:flutter/material.dart';
import '../firebase/firestore_service.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';

class CommentProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CommentModel> _comments = [];
  bool _isLoading = false;
  StreamSubscription<List<CommentModel>>? _commentsSubscription;

  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Listen to comments stream in real-time when viewing a post
  void subscribeToComments(String postId) {
    _isLoading = true;
    _commentsSubscription?.cancel();
    _commentsSubscription = _firestoreService.getCommentsStream(postId).listen(
      (updatedComments) {
        _comments = updatedComments;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Add a new comment to a post
  Future<void> addComment({
    required String postId,
    required String content,
    required String postAuthorId,
    required UserModel currentPoster,
  }) async {
    _setLoading(true);
    try {
      final comment = CommentModel(
        id: '', // Firestore will automatically generate the ID
        postId: postId,
        authorId: currentPoster.uid,
        authorName: currentPoster.displayName,
        authorPhotoUrl: currentPoster.photoUrl,
        content: content,
        createdAt: DateTime.now(),
      );

      await _firestoreService.addComment(comment, postAuthorId, currentPoster);
    } finally {
      _setLoading(false);
    }
  }

  // Cancel the subscription when we exit the post details screen to save resources
  void unsubscribeFromComments() {
    _commentsSubscription?.cancel();
    _comments = [];
  }

  @override
  void dispose() {
    _commentsSubscription?.cancel();
    super.dispose();
  }
}
