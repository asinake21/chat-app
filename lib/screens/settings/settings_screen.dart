import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // App Settings section
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Theme Mode'),
                  subtitle: const Text('Toggle between dark and light themes'),
                  value: themeProvider.isDarkMode,
                  onChanged: (bool value) {
                    themeProvider.toggleTheme(value);
                  },
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // About App / Info section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
                  title: const Text('CampusLink Version'),
                  trailing: const Text(
                    '1.0.0',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.security_outlined, color: theme.colorScheme.primary),
                  title: const Text('Privacy & Security'),
                  subtitle: const Text('Configure accounts and data sync policies'),
                  onTap: () {
                    Helpers.showSnackBar(
                      context,
                      'Privacy policies are handled by Google Firebase credentials security rules.',
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Logout Action card
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('Sign out of your active student session'),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Log Out'),
                    content: const Text('Are you sure you want to log out of CampusLink?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                        child: const Text('Log Out'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
