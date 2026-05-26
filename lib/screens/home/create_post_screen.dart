import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/custom_button.dart';
import '../../core/utils/helpers.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    final content = _textController.text.trim();
    if (content.isEmpty) {
      Helpers.showSnackBar(context, 'Please add some text to share', isError: true);
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final currentUser = authProvider.userModel;

    if (currentUser == null) {
      Helpers.showSnackBar(context, 'Authentication required to post', isError: true);
      return;
    }

    try {
      await postProvider.createPost(
        content: content,
        currentUser: currentUser,
      );
      if (mounted) {
        Helpers.showSnackBar(context, 'Post shared successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          e.toString().replaceAll('Exception:', '').trim(),
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          TextButton(
            onPressed: postProvider.isLoading ? null : _submitPost,
            child: postProvider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Share',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text Composer Area
            TextField(
              controller: _textController,
              maxLines: 6,
              minLines: 3,
              style: const TextStyle(fontSize: 16),
              enabled: !postProvider.isLoading,
              decoration: InputDecoration(
                hintText: "What's happening on campus?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                contentPadding: const EdgeInsets.all(16.0),
              ),
            ),
            const SizedBox(height: 24),

            // Share Button
            CustomButton(
              text: 'Share Post',
              onPressed: _submitPost,
              isLoading: postProvider.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
