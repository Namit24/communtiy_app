import 'package:flutter/material.dart';
import 'package:flutter_community_app/models/forum_post.dart';
import 'package:flutter_community_app/models/user.dart';
import 'package:flutter_community_app/services/auth_service.dart';
import 'package:flutter_community_app/services/data_service.dart';
import 'package:flutter_community_app/theme/app_theme.dart';
import 'package:flutter_community_app/widgets/bottom_nav_bar.dart';
import 'package:flutter_community_app/widgets/forum_post_card.dart';
import 'package:flutter_community_app/widgets/user_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<ForumPost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dataService = ref.read(dataServiceProvider);
      final posts = await dataService.fetchPosts();

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Connect'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User profile card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    UserAvatar(
                      radius: 30,
                      avatarUrl: currentUser?.avatarUrl,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser?.name ?? 'Loading...',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _buildUserSubtitle(currentUser),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        // Navigate to edit profile
                        context.push('/profile-setup');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Department forums section
            Text(
              'Your Department Forums',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildForumCard(
                    context,
                    'AIDS',
                    'Artificial Intelligence & Data Science',
                    Icons.psychology,
                    Colors.purple,
                    'aids',
                  ),
                  _buildForumCard(
                    context,
                    'CS',
                    'Computer Science',
                    Icons.computer,
                    Colors.blue,
                    'cs',
                  ),
                  _buildForumCard(
                    context,
                    'IT',
                    'Information Technology',
                    Icons.devices,
                    Colors.teal,
                    'it',
                  ),
                  _buildForumCard(
                    context,
                    'EXTC',
                    'Electronics & Telecom',
                    Icons.settings_input_antenna,
                    Colors.orange,
                    'extc',
                  ),
                  _buildForumCard(
                    context,
                    'MECH',
                    'Mechanical Engineering',
                    Icons.precision_manufacturing,
                    Colors.brown,
                    'mech',
                  ),
                  _buildForumCard(
                    context,
                    'CIVIL',
                    'Civil Engineering',
                    Icons.domain,
                    Colors.green,
                    'civil',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent posts section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Posts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // View all posts
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Posts list
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_posts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.post_add,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No posts yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to create a post!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _posts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return ForumPostCard(post: _posts[index]);
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new post
          _showCreatePostDialog(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  String _buildUserSubtitle(User? user) {
    if (user == null) {
      return 'Loading...';
    }

    String subtitle = '';

    if (user.year != null && user.year!.isNotEmpty) {
      subtitle += user.year!;
    }

    if (user.department != null && user.department!.isNotEmpty) {
      if (subtitle.isNotEmpty) {
        subtitle += ' - ';
      }
      subtitle += user.department!;
    }

    if (subtitle.isEmpty) {
      subtitle = 'Complete your profile';
    }

    return subtitle;
  }

  Widget _buildForumCard(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      Color color,
      String departmentId,
      ) {
    return GestureDetector(
      onTap: () {
        // Navigate to forum
        context.push('/forums/$departmentId');
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.subtitleColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    final textController = TextEditingController();
    final currentUser = ref.read(currentUserProvider).value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  UserAvatar(
                    radius: 20,
                    avatarUrl: currentUser?.avatarUrl,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Create Post',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: 'What\'s on your mind?',
                  border: InputBorder.none,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image_outlined),
                    onPressed: () {
                      // Add image
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () {
                      // Add attachment
                    },
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      // Submit post
                      if (textController.text.trim().isNotEmpty) {
                        // TODO: Implement post creation
                        // For now, just close the dialog
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Post'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
