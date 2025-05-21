import 'package:flutter/material.dart';
import 'package:flutter_community_app/models/forum_post.dart';
import 'package:flutter_community_app/providers/auth_provider.dart';
import 'package:flutter_community_app/providers/data_provider.dart';
import 'package:flutter_community_app/providers/posts_provider.dart';
import 'package:flutter_community_app/theme/app_theme.dart';
import 'package:flutter_community_app/widgets/forum_post_card.dart';
import 'package:flutter_community_app/widgets/user_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForumScreen extends ConsumerStatefulWidget {
  final String departmentId;

  const ForumScreen({
    super.key,
    required this.departmentId,
  });

  @override
  ConsumerState<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends ConsumerState<ForumScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Recent';

  // Mock data - in a real app, this would be fetched based on departmentId
  late String _departmentName;

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
    ForumPost(
      id: '4',
      userId: 'user4',
      userName: 'Vikram Singh',
      userAvatar: null,
      department: 'Artificial Intelligence & Data Science',
      content: 'Does anyone have resources for learning deep learning? I\'m particularly interested in CNNs and RNNs.',
      likes: 15,
      comments: 5,
      timeAgo: '2d ago',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    // Initialize department name - in a real app, this would be fetched from a database
    _initDepartmentName();
  }

  void _initDepartmentName() {
    switch (widget.departmentId) {
      case 'cs':
        _departmentName = 'Computer Science';
        break;
      case 'it':
        _departmentName = 'Information Technology';
        break;
      case 'aids':
        _departmentName = 'Artificial Intelligence & Data Science';
        break;
      default:
        _departmentName = 'Department';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ForumPost> get _filteredPosts {
    List<ForumPost> filtered = _posts;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((post) {
        return post.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            post.userName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Sort based on selected filter
    switch (_selectedFilter) {
      case 'Recent':
      // Already sorted by recent
        break;
      case 'Popular':
        filtered.sort((a, b) => b.likes.compareTo(a.likes));
        break;
      case 'Most Commented':
        filtered.sort((a, b) => b.comments.compareTo(a.comments));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_departmentName Forum'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search posts...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sort by:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    DropdownButton<String>(
                      value: _selectedFilter,
                      items: const [
                        DropdownMenuItem(
                          value: 'Recent',
                          child: Text('Recent'),
                        ),
                        DropdownMenuItem(
                          value: 'Popular',
                          child: Text('Popular'),
                        ),
                        DropdownMenuItem(
                          value: 'Most Commented',
                          child: Text('Most Commented'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value!;
                        });
                      },
                      underline: Container(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredPosts.isEmpty
                ? const Center(
              child: Text('No posts found'),
            )
                : RefreshIndicator(
              onRefresh: () async {
                // Refresh posts
                ref.refresh(postsProvider);
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredPosts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return ForumPostCard(post: _filteredPosts[index]);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new post
          _showCreatePostDialog(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    final textController = TextEditingController();
    final dataService = ref.read(dataServiceProvider);
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setState) {
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
                          onPressed: isSubmitting ? null : () async {
                            if (textController.text.trim().isEmpty) {
                              return;
                            }

                            setState(() {
                              isSubmitting = true;
                            });

                            if (user != null) {
                              final success = await dataService.createPost(
                                textController.text.trim(),
                                user.id,
                                user.name,
                                user.department,
                              );

                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Post created successfully!')),
                                );
                                Navigator.pop(context);

                                // Refresh posts
                                ref.refresh(postsProvider);
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to create post. Please try again.')),
                                );
                                setState(() {
                                  isSubmitting = false;
                                });
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('You must be logged in to post')),
                              );
                              setState(() {
                                isSubmitting = false;
                              });
                            }
                          },
                          child: isSubmitting
                              ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)
                          )
                              : const Text('Post'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }
        );
      },
    );
  }
}
