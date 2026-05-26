import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/comment_provider.dart';
import '../../widgets/post_card.dart';
import '../../widgets/comment_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../core/utils/helpers.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({Key? key}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isInit = true;
  late PostModel _post;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      // Extract the PostModel passed from router arguments
      _post = ModalRoute.of(context)!.settings.arguments as PostModel;

      // Subscribe to real-time comments updates
      Provider.of<CommentProvider>(context, listen: false)
          .subscribeToComments(_post.id);
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    // Safely unsubscribe from specific comment updates
    Provider.of<CommentProvider>(context, listen: false).unsubscribeFromComments();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final commentProvider = Provider.of<CommentProvider>(context, listen: false);
    final currentUser = authProvider.userModel;

    if (currentUser == null) {
      Helpers.showSnackBar(context, 'Please log in to add comments', isError: true);
      return;
    }

    try {
      await commentProvider.addComment(
        postId: _post.id,
        content: text,
        postAuthorId: _post.authorId,
        currentPoster: currentUser,
      );
      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to add comment: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = Provider.of<CommentProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Discussion'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Render the original post card
                SliverToBoxAdapter(
                  child: PostCard(post: _post),
                ),

                // Discussion header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
                    child: Text(
                      'Comments (${commentProvider.comments.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Comments feed list
                if (commentProvider.isLoading && commentProvider.comments.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: LoadingWidget(message: 'Loading discussions...')),
                  )
                else if (commentProvider.comments.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(
                      icon: Icons.chat_bubble_outline,
                      title: 'No Comments Yet',
                      description: 'Be the first to share your thoughts about this post!',
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final comment = commentProvider.comments[index];
                        return CommentCard(comment: comment);
                      },
                      childCount: commentProvider.comments.length,
                    ),
                  ),
              ],
            ),
          ),

          // Message/Comment Input composer at the bottom
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 8,
              bottom: 8 + MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    maxLines: 3,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: theme.colorScheme.primary),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
