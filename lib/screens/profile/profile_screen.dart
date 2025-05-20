import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_community_app/theme/app_theme.dart';
import 'package:flutter_community_app/widgets/profile_avatar.dart';
import 'package:flutter_community_app/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(currentUserProvider);

    return userAsyncValue.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text('Not logged in'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: ProfileAvatar(
                    radius: 60,
                    avatarUrl: user.avatarUrl,
                    onChanged: (url) async {
                      // Update avatar
                      try {
                        final authService = ref.read(authServiceProvider);
                        await authService.updateProfile(
                          name: user.name,
                          avatarUrl: url,
                          department: user.department,
                          year: user.year,
                        );
                      } catch (e) {
                        print('Error updating avatar: $e');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.subtitleColor,
                  ),
                ),
                if (user.department != null && user.year != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${user.year} - ${user.department}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.subtitleColor,
                      ),
                    ),
                  ),
                const SizedBox(height: 32),

                // Profile actions
                _buildProfileAction(
                  context,
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () {
                    context.push('/profile-setup');
                  },
                ),
                const Divider(),
                if (user.isAdmin) ...[
                  _buildProfileAction(
                    context,
                    icon: Icons.admin_panel_settings,
                    title: 'Admin Settings',
                    onTap: () {
                      context.push('/admin/skills');
                    },
                  ),
                  const Divider(),
                ],
                _buildProfileAction(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    // Navigate to settings
                  },
                ),
                const Divider(),
                _buildProfileAction(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    // Navigate to help
                  },
                ),
                const Divider(),
                _buildProfileAction(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  isDestructive: true,
                  onTap: () async {
                    // Logout
                    try {
                      final authService = ref.read(authServiceProvider);
                      await authService.signOut();
                      if (mounted) {
                        context.go('/login');
                      }
                    } catch (e) {
                      print('Error logging out: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error logging out: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildProfileAction(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        bool isDestructive = false,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppTheme.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
