import 'package:flutter/material.dart';
import 'package:flutter_community_app/models/forum_post.dart';
import 'package:flutter_community_app/models/skill.dart';
import 'package:flutter_community_app/theme/app_theme.dart';
import 'package:flutter_community_app/widgets/forum_post_card.dart';

class SkillDetailScreen extends StatefulWidget {
  final String skillId;
  
  const SkillDetailScreen({
    super.key,
    required this.skillId,
  });

  @override
  State<SkillDetailScreen> createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends State<SkillDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data - in a real app, this would be fetched based on skillId
  late Skill _skill;
  
  final List<Map<String, dynamic>> _roadmap = [
    {
      'title': 'Fundamentals',
      'description': 'Learn the basic concepts and principles',
      'resources': [
        {'title': 'Introduction Course', 'type': 'Video', 'url': 'https://example.com'},
        {'title': 'Beginner\'s Guide', 'type': 'Article', 'url': 'https://example.com'},
        {'title': 'Practice Exercises', 'type': 'Exercise', 'url': 'https://example.com'},
      ],
      'isCompleted': false,
    },
    {
      'title': 'Intermediate Concepts',
      'description': 'Dive deeper into advanced topics',
      'resources': [
        {'title': 'Advanced Techniques', 'type': 'Video', 'url': 'https://example.com'},
        {'title': 'Case Studies', 'type': 'Article', 'url': 'https://example.com'},
        {'title': 'Hands-on Project', 'type': 'Project', 'url': 'https://example.com'},
      ],
      'isCompleted': false,
    },
    {
      'title': 'Advanced Applications',
      'description': 'Apply your knowledge to real-world problems',
      'resources': [
        {'title': 'Expert Workshop', 'type': 'Video', 'url': 'https://example.com'},
        {'title': 'Research Papers', 'type': 'Article', 'url': 'https://example.com'},
        {'title': 'Capstone Project', 'type': 'Project', 'url': 'https://example.com'},
      ],
      'isCompleted': false,
    },
  ];
  
  final List<ForumPost> _posts = [
    ForumPost(
      id: '1',
      userId: 'user1',
      userName: 'Priya Sharma',
      userAvatar: null,
      department: 'Artificial Intelligence & Data Science',
      content: 'Has anyone completed the Machine Learning certification? Is it worth it?',
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
      content: 'I\'m looking for study partners for the upcoming ML project. Anyone interested?',
      likes: 12,
      comments: 7,
      timeAgo: '5h ago',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Mock data initialization - in a real app, this would be fetched from a database
    _skill = _getMockSkill(widget.skillId);
  }

  Skill _getMockSkill(String id) {
    // This is a mock function - in a real app, you would fetch this from a database
    switch (id) {
      case '1':
        return Skill(
          id: '1',
          title: 'Machine Learning',
          category: 'AI & ML',
          description: 'Machine Learning is a field of artificial intelligence that uses statistical techniques to give computer systems the ability to "learn" from data, without being explicitly programmed. The name Machine Learning was coined in 1959 by Arthur Samuel.',
          imageUrl: null,
          level: 'Intermediate',
          estimatedTime: '3 months',
          popularity: 95,
        );
      case '2':
        return Skill(
          id: '2',
          title: 'Web Development',
          category: 'Web Development',
          description: 'Web development is the work involved in developing a website for the Internet or an intranet. Web development can range from developing a simple single static page of plain text to complex web applications, electronic businesses, and social network services.',
          imageUrl: null,
          level: 'Beginner to Advanced',
          estimatedTime: '6 months',
          popularity: 98,
        );
      default:
        return Skill(
          id: '3',
          title: 'Flutter Development',
          category: 'Mobile Development',
          description: 'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase. Flutter works with existing code, is used by developers and organizations around the world, and is free and open source.',
          imageUrl: null,
          level: 'Intermediate',
          estimatedTime: '4 months',
          popularity: 90,
        );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_skill.title),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getIconForCategory(_skill.category),
                    size: 80,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(_skill.category),
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(_skill.level),
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        side: BorderSide(color: Colors.orange.withOpacity(0.3)),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(_skill.estimatedTime),
                        backgroundColor: Colors.green.withOpacity(0.1),
                        side: BorderSide(color: Colors.green.withOpacity(0.3)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'About this Skill',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _skill.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: AppTheme.subtitleColor,
                    indicatorColor: AppTheme.primaryColor,
                    tabs: const [
                      Tab(text: 'Learning Path'),
                      Tab(text: 'Discussion'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Learning Path Tab
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _roadmap.length,
                  itemBuilder: (context, index) {
                    final step = _roadmap[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppTheme.primaryColor,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    step['title'],
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Checkbox(
                                  value: step['isCompleted'],
                                  onChanged: (value) {
                                    setState(() {
                                      _roadmap[index]['isCompleted'] = value;
                                    });
                                  },
                                  activeColor: AppTheme.primaryColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              step['description'],
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Resources',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...List.generate(
                              step['resources'].length,
                              (i) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  _getIconForResourceType(step['resources'][i]['type']),
                                  color: AppTheme.primaryColor,
                                ),
                                title: Text(step['resources'][i]['title']),
                                subtitle: Text(step['resources'][i]['type']),
                                trailing: const Icon(Icons.open_in_new),
                                onTap: () {
                                  // Open resource URL
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                // Discussion Tab
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Create new post
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Start a Discussion'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._posts.map((post) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ForumPostCard(post: post),
                    )).toList(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'AI & ML':
        return Icons.psychology;
      case 'Web Development':
        return Icons.web;
      case 'Mobile Development':
        return Icons.phone_android;
      case 'Data Science':
        return Icons.analytics;
      case 'Cloud Computing':
        return Icons.cloud;
      case 'Cybersecurity':
        return Icons.security;
      default:
        return Icons.code;
    }
  }

  IconData _getIconForResourceType(String type) {
    switch (type) {
      case 'Video':
        return Icons.video_library;
      case 'Article':
        return Icons.article;
      case 'Exercise':
        return Icons.assignment;
      case 'Project':
        return Icons.build;
      default:
        return Icons.link;
    }
  }
}
