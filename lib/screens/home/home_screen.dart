import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/post_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../core/routes/app_routes.dart';

// Sub-screens for each tab in bottom navigation
import '../profile/profile_screen.dart';
import '../notifications/notification_screen.dart';
import '../settings/settings_screen.dart';

// Main screen shell containing the bottom navigation bar and the appbar
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // These are the main tabs inside our navigation bar
  final List<Widget> _tabs = [
    const FeedTab(),
    const NotificationScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = [
    'CampusLink Feed',
    'Notifications',
    'My Profile',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: theme.appBarTheme.titleTextStyle,
        ),
        actions: _currentIndex == 2 // Show shortcut to settings only when viewing profile tab
            ? [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    setState(() {
                      _currentIndex = 3; // Switch to settings tab
                    });
                  },
                ),
              ]
            : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.createPost);
              },
              icon: const Icon(Icons.add_comment_outlined),
              label: const Text('Create Post'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// The home feed tab that displays all student posts in real-time
class FeedTab extends StatelessWidget {
  const FeedTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    if (postProvider.isLoading && postProvider.posts.isEmpty) {
      return const Center(child: LoadingWidget(message: 'Fetching student feed...'));
    }

    if (postProvider.posts.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.forum_outlined,
        title: 'Empty Feed',
        description: 'Be the first to share something with your campus peer groups!',
        actionText: 'Compose Post',
        onActionPressed: () {
          Navigator.pushNamed(context, AppRoutes.createPost);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // We use real-time listeners, but this dummy delay gives standard pull-to-refresh feel
        await Future.delayed(const Duration(milliseconds: 800));
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 84), // Extra bottom padding so the fab doesn't block the last post
        itemCount: postProvider.posts.length,
        itemBuilder: (context, index) {
          final post = postProvider.posts[index];
          return PostCard(post: post);
        },
      ),
    );
  }
}
