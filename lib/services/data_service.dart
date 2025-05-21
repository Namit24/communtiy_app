import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_community_app/models/note.dart';
import 'package:flutter_community_app/models/paper.dart';
import 'package:flutter_community_app/models/skill.dart';
import 'package:flutter_community_app/models/forum_post.dart';
import 'package:flutter_community_app/models/chat.dart';
import 'package:flutter_community_app/services/supabase_service.dart';

// Service to handle data operations
class DataService {
  final SupabaseService _supabaseService;

  DataService(this._supabaseService);

  // Note methods
  Future<List<Note>> fetchNotes() async {
    try {
      // In a real app, this would fetch from Supabase
      // For now, return mock data
      await Future.delayed(const Duration(seconds: 1));
      return _getMockNotes();
    } catch (e) {
      print('Error fetching notes: $e');
      return [];
    }
  }

  Future<Note?> getNoteById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockNotes().firstWhere((note) => note.id == id);
    } catch (e) {
      print('Error getting note by ID: $e');
      return null;
    }
  }

  // Paper methods
  Future<List<Paper>> fetchPapers() async {
    try {
      // In a real app, this would fetch from Supabase
      // For now, return mock data
      await Future.delayed(const Duration(seconds: 1));
      return _getMockPapers();
    } catch (e) {
      print('Error fetching papers: $e');
      return [];
    }
  }

  Future<Paper?> getPaperById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockPapers().firstWhere((paper) => paper.id == id);
    } catch (e) {
      print('Error getting paper by ID: $e');
      return null;
    }
  }

  // Skill methods
  Future<List<Skill>> fetchSkills() async {
    try {
      // In a real app, this would fetch from Supabase
      // For now, return mock data
      await Future.delayed(const Duration(seconds: 1));
      return _getMockSkills();
    } catch (e) {
      print('Error fetching skills: $e');
      return [];
    }
  }

  Future<Skill?> getSkillById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockSkills().firstWhere((skill) => skill.id == id);
    } catch (e) {
      print('Error getting skill by ID: $e');
      return null;
    }
  }

  // Forum post methods
  Future<List<ForumPost>> fetchPosts() async {
    try {
      // In a real app, this would fetch from Supabase
      // For now, return an empty list as requested
      await Future.delayed(const Duration(seconds: 1));
      return [];
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }

  Future<ForumPost?> getPostById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final posts = _getMockPosts();
      if (posts.any((post) => post.id == id)) {
        return posts.firstWhere((post) => post.id == id);
      }
      return null;
    } catch (e) {
      print('Error getting post by ID: $e');
      return null;
    }
  }

  // Chat methods
  Future<List<Chat>> fetchChats() async {
    try {
      // In a real app, this would fetch from Supabase
      // For now, return mock data
      await Future.delayed(const Duration(seconds: 1));
      return _getMockChats();
    } catch (e) {
      print('Error fetching chats: $e');
      return [];
    }
  }

  Future<Chat?> getChatById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockChats().firstWhere((chat) => chat.id == id);
    } catch (e) {
      print('Error getting chat by ID: $e');
      return null;
    }
  }

  // Create a new post
  Future<bool> createPost(String content, String userId, String userName, String? department) async {
    try {
      // In a real app, this would create a post in Supabase
      final client = _supabaseService.client;

      final newPost = {
        'user_id': userId,
        'user_name': userName,
        'department': department,
        'content': content,
        'likes': 0,
        'comments': 0,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await client.from('posts').insert(newPost);
      print('Post created successfully: $response');
      return true;
    } catch (e) {
      print('Error creating post: $e');
      return false;
    }
  }

  // Mock data methods
  List<Note> _getMockNotes() {
    return [
      Note(
        id: '1',
        title: 'Machine Learning Fundamentals',
        subject: 'Artificial Intelligence',
        uploadedBy: 'Prof. Sharma',
        uploadDate: '10 May 2023',
        fileSize: '2.5 MB',
        fileType: 'PDF',
        downloadCount: 120,
      ),
      Note(
        id: '2',
        title: 'Data Structures and Algorithms',
        subject: 'Computer Science',
        uploadedBy: 'Rahul Patel',
        uploadDate: '5 June 2023',
        fileSize: '1.8 MB',
        fileType: 'PDF',
        downloadCount: 85,
      ),
      Note(
        id: '3',
        title: 'Database Management Systems',
        subject: 'Information Technology',
        uploadedBy: 'Ananya Gupta',
        uploadDate: '20 April 2023',
        fileSize: '3.2 MB',
        fileType: 'PDF',
        downloadCount: 150,
      ),
      Note(
        id: '4',
        title: 'Neural Networks and Deep Learning',
        subject: 'Artificial Intelligence',
        uploadedBy: 'Prof. Kumar',
        uploadDate: '15 July 2023',
        fileSize: '4.5 MB',
        fileType: 'PDF',
        downloadCount: 95,
      ),
    ];
  }

  List<Paper> _getMockPapers() {
    return [
      Paper(
        id: '1',
        title: 'Machine Learning End Semester',
        subject: 'Machine Learning',
        year: '2023',
        examType: 'End Semester',
        uploadedBy: 'Prof. Sharma',
        uploadDate: '15 June 2023',
        fileSize: '1.2 MB',
        fileType: 'PDF',
        downloadCount: 85,
      ),
      Paper(
        id: '2',
        title: 'Data Structures Mid Semester',
        subject: 'Data Structures',
        year: '2023',
        examType: 'Mid Semester',
        uploadedBy: 'Prof. Patel',
        uploadDate: '10 March 2023',
        fileSize: '0.8 MB',
        fileType: 'PDF',
        downloadCount: 120,
      ),
      Paper(
        id: '3',
        title: 'Database Systems End Semester',
        subject: 'Database Systems',
        year: '2022',
        examType: 'End Semester',
        uploadedBy: 'Prof. Gupta',
        uploadDate: '20 December 2022',
        fileSize: '1.5 MB',
        fileType: 'PDF',
        downloadCount: 95,
      ),
      Paper(
        id: '4',
        title: 'Computer Networks Mid Semester',
        subject: 'Computer Networks',
        year: '2022',
        examType: 'Mid Semester',
        uploadedBy: 'Prof. Kumar',
        uploadDate: '5 October 2022',
        fileSize: '1.0 MB',
        fileType: 'PDF',
        downloadCount: 75,
      ),
    ];
  }

  List<Skill> _getMockSkills() {
    return [
      Skill(
        id: '1',
        title: 'Machine Learning',
        category: 'AI & ML',
        description: 'Learn the fundamentals of machine learning algorithms and applications.',
        imageUrl: null,
        level: 'Intermediate',
        estimatedTime: '3 months',
        popularity: 95,
      ),
      Skill(
        id: '2',
        title: 'Web Development',
        category: 'Web Development',
        description: 'Master modern web development with HTML, CSS, JavaScript, and popular frameworks.',
        imageUrl: null,
        level: 'Beginner to Advanced',
        estimatedTime: '6 months',
        popularity: 98,
      ),
      Skill(
        id: '3',
        title: 'Flutter Development',
        category: 'Mobile Development',
        description: 'Build beautiful cross-platform mobile apps with Flutter and Dart.',
        imageUrl: null,
        level: 'Intermediate',
        estimatedTime: '4 months',
        popularity: 90,
      ),
      Skill(
        id: '4',
        title: 'Data Science',
        category: 'Data Science',
        description: 'Learn data analysis, visualization, and statistical modeling techniques.',
        imageUrl: null,
        level: 'Intermediate to Advanced',
        estimatedTime: '5 months',
        popularity: 92,
      ),
      Skill(
        id: '5',
        title: 'Cloud Computing',
        category: 'Cloud Computing',
        description: 'Master cloud platforms like AWS, Azure, and Google Cloud.',
        imageUrl: null,
        level: 'Intermediate',
        estimatedTime: '3 months',
        popularity: 88,
      ),
    ];
  }

  List<ForumPost> _getMockPosts() {
    return [
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
  }

  List<Chat> _getMockChats() {
    return [
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
  }
}

// Provider for data service
final dataServiceProvider = Provider<DataService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return DataService(supabaseService);
});

// Providers for data
final notesProvider = FutureProvider<List<Note>>((ref) {
  final dataService = ref.watch(dataServiceProvider);
  return dataService.fetchNotes();
});

final papersProvider = FutureProvider<List<Paper>>((ref) {
  final dataService = ref.watch(dataServiceProvider);
  return dataService.fetchPapers();
});

final skillsProvider = FutureProvider<List<Skill>>((ref) {
  final dataService = ref.watch(dataServiceProvider);
  return dataService.fetchSkills();
});

final postsProvider = FutureProvider<List<ForumPost>>((ref) {
  final dataService = ref.watch(dataServiceProvider);
  return dataService.fetchPosts();
});

final chatsProvider = FutureProvider<List<Chat>>((ref) {
  final dataService = ref.watch(dataServiceProvider);
  return dataService.fetchChats();
});
