import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../firebase/firestore_service.dart';
import '../../models/notification_model.dart';
import '../../models/post_model.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/user_avatar.dart';
import '../../core/utils/helpers.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/app_constants.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;
    final firestoreService = FirestoreService();
    final theme = Theme.of(context);

    if (user == null) {
      return const Center(child: LoadingWidget(message: 'Loading activities...'));
    }

    return Scaffold(
      body: StreamBuilder<List<NotificationModel>>(
        stream: firestoreService.getNotificationsStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingWidget(message: 'Loading notifications...'));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading notifications: ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.notifications_none_outlined,
              title: 'No Notifications',
              description: 'When students like or comment on your posts, you will see it here!',
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final isLike = notif.type == 'like';

              return Container(
                color: notif.isRead 
                    ? Colors.transparent 
                    : theme.colorScheme.primary.withOpacity(0.05),
                child: ListTile(
                  leading: UserAvatar(
                    photoUrl: notif.senderPhotoUrl,
                    radius: 20,
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: theme.colorScheme.onBackground,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: notif.senderName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: isLike ? ' liked your post.' : ' commented on your post.',
                        ),
                      ],
                    ),
                  ),
                  subtitle: Text(
                    Helpers.timeAgo(notif.createdAt),
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    isLike ? Icons.favorite : Icons.chat_bubble,
                    color: isLike ? theme.colorScheme.error : theme.colorScheme.primary,
                    size: 18,
                  ),
                  onTap: () async {
                    // 1. Mark as read
                    if (!notif.isRead) {
                      await firestoreService.markNotificationAsRead(notif.id);
                    }

                    // 2. Fetch post details and route
                    if (context.mounted) {
                      _fetchAndRouteToPost(context, notif.postId);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Fetches the post document from Firestore to pass into detail screen argument
  Future<void> _fetchAndRouteToPost(BuildContext context, String postId) async {
    // Show circular loader overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    try {
      final doc = await FirebaseFirestore.instance
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .get();

      if (context.mounted) Navigator.pop(context); // Dismiss loading dialog

      if (doc.exists && doc.data() != null) {
        final post = PostModel.fromMap(doc.data()!, doc.id);
        if (context.mounted) {
          Navigator.pushNamed(
            context,
            AppRoutes.postDetail,
            arguments: post,
          );
        }
      } else {
        if (context.mounted) {
          Helpers.showSnackBar(context, 'This post has been deleted by the author', isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        Helpers.showSnackBar(context, 'Error loading post details', isError: true);
      }
    }
  }
}
