import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_community_app/models/chat.dart';
import 'package:flutter_community_app/theme/app_theme.dart';
import 'package:flutter_community_app/widgets/bottom_nav_bar.dart';
import 'package:flutter_community_app/widgets/chat_list_item.dart';
import 'package:flutter_community_app/widgets/user_avatar.dart';
import 'package:flutter_community_app/services/data_service.dart';
import 'package:go_router/go_router.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Chat> _chats = [];
  List<Chat> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dataService = ref.read(dataServiceProvider);
      final conversations = await dataService.getConversations();

      setState(() {
        // Filter accepted chats and pending requests
        _chats = conversations.where((chat) => chat.isAccepted).toList();
        _requests = conversations.where((chat) => !chat.isAccepted).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading chats: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
              controller: _tabController,
              children: [
                // Chats Tab
                _filteredChats.isEmpty
                    ? const Center(
                  child: Text('No chats found'),
                )
                    : RefreshIndicator(
                  onRefresh: _loadChats,
                  child: ListView.separated(
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
                ),

                // Requests Tab
                _filteredRequests.isEmpty
                    ? const Center(
                  child: Text('No requests found'),
                )
                    : RefreshIndicator(
                  onRefresh: _loadChats,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredRequests.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ChatListItem(
                            chat: _filteredRequests[index],
                            onTap: () {
                              // View request details
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () async {
                                  // Decline request
                                  try {
                                    final dataService = ref.read(dataServiceProvider);
                                    await dataService.declineMessageRequest(_filteredRequests[index].id);
                                    _loadChats();
                                  } catch (e) {
                                    print('Error declining request: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error declining request: $e')),
                                    );
                                  }
                                },
                                child: const Text('Decline'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  // Accept request
                                  try {
                                    final dataService = ref.read(dataServiceProvider);
                                    await dataService.acceptMessageRequest(_filteredRequests[index].id);
                                    _loadChats();
                                  } catch (e) {
                                    print('Error accepting request: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error accepting request: $e')),
                                    );
                                  }
                                },
                                child: const Text('Accept'),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
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
    final searchController = TextEditingController();
    String searchQuery = '';
    List<dynamic> users = [];
    bool isLoading = true;

    // Load users
    Future<void> loadUsers() async {
      try {
        final dataService = ref.read(dataServiceProvider);
        final fetchedUsers = await dataService.getUsers();
        users = fetchedUsers;
        isLoading = false;
      } catch (e) {
        print('Error loading users: $e');
        isLoading = false;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Load users when dialog opens
            if (isLoading) {
              loadUsers().then((_) {
                setState(() {});
              });
            }

            // Filter users based on search query
            final filteredUsers = searchQuery.isEmpty
                ? users
                : users.where((user) {
              return user['name'].toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

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
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : filteredUsers.isEmpty
                          ? const Center(child: Text('No users found'))
                          : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredUsers.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return ListTile(
                            leading: UserAvatar(
                              radius: 20,
                              avatarUrl: user['avatarUrl'],
                            ),
                            title: Text(user['name']),
                            subtitle: Text(
                              user['department'] ?? 'No department',
                              style: TextStyle(
                                color: AppTheme.subtitleColor,
                              ),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                // Send message request
                                try {
                                  final dataService = ref.read(dataServiceProvider);
                                  await dataService.sendMessageRequest(user['id']);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Message request sent')),
                                  );
                                  _loadChats();
                                } catch (e) {
                                  print('Error sending message request: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error sending message request: $e')),
                                  );
                                }
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
      },
    );
  }
}
