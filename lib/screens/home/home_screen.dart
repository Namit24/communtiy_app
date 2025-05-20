import 'package:flutter/material.dart';
import 'package:flutter_community_app/models/forum_post.dart';
import 'package:flutter_community_app/theme/app_theme.dart';
import 'package:flutter_community_app/widgets/bottom_nav_bar.dart';
import 'package:flutter_community_app/widgets/forum_post_card.dart';
import 'package:flutter_community_app/widgets/user_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<ForumPost> _posts = [
    ForumPost(
      id: '1',
      userId: 'user1',
      userName: 'Priya Sharma',
      userAvatar: null,
      department: 'Artificial Intelligence & Data Science',
      content: 'Has anyone completed the Machine Learning assignment? I\'m stuck on the clustering algorithm part.',
      likes: 5,
      comments: 3,
      timeAgo: '2h ago',
    ),
    ForumPost(
      id: '2',
      userId: 'user2',
      userName: 'Rahul Patel',
      userAvatar: null,
      department: 'Computer Science',
      content: 'I\'m organizing a web development workshop this weekend. Anyone interested can DM me for details!',
      likes: 12,
      comments: 7,
      timeAgo: '5h ago',
    ),
    ForumPost(
      id: '3',
      userId: 'user3',
      userName: 'Ananya Gupta',
      userAvatar: null,
      department: 'Information Technology',
      content: 'Looking for study partners for the upcoming database exam. We can meet in the library.',
      likes: 8,
      comments: 10,
      timeAgo: '1d ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
        onRefresh: () async {
          // Refresh posts
          await Future.delayed(const Duration(seconds: 1));
        },
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
                    const UserAvatar(
                      radius: 30,
                      avatarUrl: null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Namit Solanki',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'SY - Artificial Intelligence & Data Science',
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
                  ),
                  _buildForumCard(
                    context,
                    'CS',
                    'Computer Science',
                    Icons.computer,
                    Colors.blue,
                  ),
                  _buildForumCard(
                    context,
                    'IT',
                    'Information Technology',
                    Icons.devices,
                    Colors.teal,
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

  Widget _buildForumCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to forum
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
                  const UserAvatar(
                    radius: 20,
                    avatarUrl: null,
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
                      Navigator.pop(context);
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
