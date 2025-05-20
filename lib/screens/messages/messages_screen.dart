import 'package:flutter/material.dart';
import 'package:flutter_community_app/models/chat.dart';
import 'package:flutter_community_app/theme/app_theme.dart';
import 'package:flutter_community_app/widgets/bottom_nav_bar.dart';
import 'package:flutter_community_app/widgets/chat_list_item.dart';
import 'package:flutter_community_app/widgets/user_avatar.dart';
import 'package:go_router/go_router.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Chat> _chats = [
    Chat(
      id: '1',
      userId: 'user1',
      userName: 'Priya Sharma',
      userAvatar: null,
      lastMessage: 'Hey, did you get the notes from yesterday\'s class?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      unreadCount: 2,
      isOnline: true,
    ),
    Chat(
      id: '2',
      userId: 'user2',
      userName: 'Rahul Patel',
      userAvatar: null,
      lastMessage: 'Thanks for sharing the project details!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
      isOnline: false,
    ),
    Chat(
      id: '3',
      userId: 'user3',
      userName: 'Ananya Gupta',
      userAvatar: null,
      lastMessage: 'Let\'s meet at the library tomorrow at 3 PM',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      isOnline: true,
    ),
  ];

  final List<Chat> _requests = [
    Chat(
      id: '4',
      userId: 'user4',
      userName: 'Vikram Singh',
      userAvatar: null,
      lastMessage: 'Hi, I\'m interested in joining your study group for ML.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      unreadCount: 1,
      isOnline: false,
    ),
    Chat(
      id: '5',
      userId: 'user5',
      userName: 'Neha Patel',
      userAvatar: null,
      lastMessage: 'Hello, I saw your post about the web dev workshop.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      unreadCount: 1,
      isOnline: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Chat> get _filteredChats {
    if (_searchQuery.isEmpty) {
      return _chats;
    }
    return _chats.where((chat) {
      return chat.userName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Chat> get _filteredRequests {
    if (_searchQuery.isEmpty) {
      return _requests;
    }
    return _requests.where((chat) {
      return chat.userName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.subtitleColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search messages...',
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
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Chats Tab
                _filteredChats.isEmpty
                    ? const Center(
                        child: Text('No chats found'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredChats.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          return ChatListItem(
                            chat: _filteredChats[index],
                            onTap: () {
                              context.go('/chat/${_filteredChats[index].userId}');
                            },
                          );
                        },
                      ),
                
                // Requests Tab
                _filteredRequests.isEmpty
                    ? const Center(
                        child: Text('No requests found'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredRequests.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ChatListItem(
                                chat: _filteredRequests[index],
                                onTap: () {
                                  // View request
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      // Decline request
                                      setState(() {
                                        _requests.removeAt(index);
                                      });
                                    },
                                    child: const Text('Decline'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Accept request
                                      final request = _requests[index];
                                      setState(() {
                                        _requests.removeAt(index);
                                        _chats.add(request);
                                      });
                                    },
                                    child: const Text('Accept'),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Start new chat
          _showNewChatDialog(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.chat),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'New Message',
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
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: 10, // Mock user list
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const UserAvatar(
                          radius: 20,
                          avatarUrl: null,
                        ),
                        title: Text('User ${index + 1}'),
                        subtitle: Text(
                          index % 2 == 0 ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: index % 2 == 0 ? Colors.green : AppTheme.subtitleColor,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // Send message request
                            Navigator.pop(context);
                          },
                          child: const Text('Message'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
