import 'package:flutter/material.dart';
import 'package:flutter_community_app/theme/app_theme.dart';
import 'package:flutter_community_app/widgets/message_bubble.dart';
import 'package:flutter_community_app/widgets/user_avatar.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  
  const ChatScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAttachmentMenuOpen = false;
  
  // Mock data - in a real app, this would be fetched based on userId
  late String _userName;
  late bool _isOnline;
  
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'senderId': 'user1',
      'text': 'Hey, did you get the notes from yesterday\'s class?',
      'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      'isRead': true,
    },
    {
      'id': '2',
      'senderId': 'currentUser',
      'text': 'Yes, I did! Let me share them with you.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 55)),
      'isRead': true,
    },
    {
      'id': '3',
      'senderId': 'currentUser',
      'text': 'Here you go! I\'ve also included some additional resources that might be helpful.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 50)),
      'isRead': true,
    },
    {
      'id': '4',
      'senderId': 'user1',
      'text': 'Thank you so much! This is really helpful.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 40)),
      'isRead': true,
    },
    {
      'id': '5',
      'senderId': 'user1',
      'text': 'By the way, are you planning to attend the workshop this weekend?',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'isRead': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize mock data - in a real app, this would be fetched from a database
    _initMockData();
    
    // Scroll to bottom when opening chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _initMockData() {
    switch (widget.userId) {
      case 'user1':
        _userName = 'Priya Sharma';
        _isOnline = true;
        break;
      case 'user2':
        _userName = 'Rahul Patel';
        _isOnline = false;
        break;
      case 'user3':
        _userName = 'Ananya Gupta';
        _isOnline = true;
        break;
      default:
        _userName = 'User';
        _isOnline = false;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'senderId': 'currentUser',
        'text': text,
        'timestamp': DateTime.now(),
        'isRead': false,
      });
      _messageController.clear();
    });
    
    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            UserAvatar(
              radius: 16,
              avatarUrl: null,
              showBadge: _isOnline,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isOnline ? Colors.green : AppTheme.subtitleColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // Voice call
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // Video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // More options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['senderId'] == 'currentUser';
                
                return MessageBubble(
                  message: message['text'],
                  isMe: isMe,
                  time: message['timestamp'],
                  isRead: message['isRead'],
                );
              },
            ),
          ),
          if (_isAttachmentMenuOpen)
            Container(
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentButton(Icons.image, 'Image', Colors.purple),
                  _buildAttachmentButton(Icons.camera_alt, 'Camera', Colors.pink),
                  _buildAttachmentButton(Icons.insert_drive_file, 'Document', Colors.blue),
                  _buildAttachmentButton(Icons.location_on, 'Location', Colors.green),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isAttachmentMenuOpen ? Icons.close : Icons.attach_file,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isAttachmentMenuOpen = !_isAttachmentMenuOpen;
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.primaryColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color,
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: () {
              // Handle attachment
              setState(() {
                _isAttachmentMenuOpen = false;
              });
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
