import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/post_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/user_avatar.dart';
import '../../core/utils/helpers.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userModel != null) {
        // Subscribe to posts published by this active user
        Provider.of<PostProvider>(context, listen: false)
            .subscribeToUserPosts(authProvider.userModel!.uid);
      }
      _isInit = false;
    }
  }

  void _showEditProfileBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const EditProfileForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final user = authProvider.userModel;
    final theme = Theme.of(context);

    if (user == null) {
      return const Center(child: LoadingWidget(message: 'Loading user details...'));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Profile Details Header Card
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar & Edit Profile Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      UserAvatar(
                        photoUrl: user.photoUrl,
                        radius: 40,
                      ),
                      Column(
                        children: [
                          OutlinedButton(
                            onPressed: () => _showEditProfileBottomSheet(context),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Edit Profile'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // User Info
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      user.displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      user.email,
                      style: TextStyle(
                        color: theme.hintColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bio Description
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      user.bio,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // User Posts Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 24, bottom: 8),
              child: Text(
                'My Posts (${postProvider.userPosts.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // User Posts list
          if (postProvider.isLoading && postProvider.userPosts.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: LoadingWidget(message: 'Loading posts...')),
            )
          else if (postProvider.userPosts.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateWidget(
                icon: Icons.note_alt_outlined,
                title: 'No Posts Yet',
                description: "You haven't written any posts yet. Start composing to share details with friends!",
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = postProvider.userPosts[index];
                  return PostCard(post: post);
                },
                childCount: postProvider.userPosts.length,
              ),
            ),
        ],
      ),
    );
  }
}

/// Internal Bottom Sheet form for Editing Profile details
class EditProfileForm extends StatefulWidget {
  const EditProfileForm({Key? key}) : super(key: key);

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).userModel;
    _nameController = TextEditingController(text: user?.displayName);
    _bioController = TextEditingController(text: user?.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.updateProfile(
          displayName: _nameController.text.trim(),
          bio: _bioController.text.trim(),
        );
        if (mounted) {
          Helpers.showSnackBar(context, 'Profile updated successfully!');
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          Helpers.showSnackBar(context, 'Failed to update profile: $e', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Profile Image Preview
            Center(
              child: UserAvatar(
                photoUrl: user?.photoUrl ?? '',
                radius: 50,
              ),
            ),
            const SizedBox(height: 24),

            // Fields
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio',
                prefixIcon: Icon(Icons.info_outline),
              ),
            ),
            const SizedBox(height: 24),

            // Action Button
            ElevatedButton(
              onPressed: authProvider.isLoading ? null : _saveProfile,
              child: authProvider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
