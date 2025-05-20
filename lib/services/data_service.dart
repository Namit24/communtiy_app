import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_community_app/models/note.dart';
import 'package:flutter_community_app/models/paper.dart';
import 'package:flutter_community_app/models/skill.dart';
import 'package:flutter_community_app/models/forum_post.dart';
import 'package:flutter_community_app/models/chat.dart';

// Service to handle data operations
class DataService {
  // Mock data repositories
  final List<Note> _notes = [
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

  final List<Paper> _papers = [
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

  final List<Skill> _skills = [
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

  // Note methods
  List<Note> getNotes() {
    return List.from(_notes);
  }

  Future<List<Note>> fetchNotes() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return getNotes();
  }

  Future<Note?> getNoteById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _notes.firstWhere((note) => note.id == id);
  }

  // Paper methods
  List<Paper> getPapers() {
    return List.from(_papers);
  }

  Future<List<Paper>> fetchPapers() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return getPapers();
  }

  Future<Paper?> getPaperById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _papers.firstWhere((paper) => paper.id == id);
  }

  // Skill methods
  List<Skill> getSkills() {
    return List.from(_skills);
  }

  Future<List<Skill>> fetchSkills() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return getSkills();
  }

  Future<Skill?> getSkillById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _skills.firstWhere((skill) => skill.id == id);
  }

  // Forum post methods
  List<ForumPost> getPosts() {
    return List.from(_posts);
  }

  Future<List<ForumPost>> fetchPosts() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return getPosts();
  }

  Future<ForumPost?> getPostById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _posts.firstWhere((post) => post.id == id);
  }

  // Chat methods
  List<Chat> getChats() {
    return List.from(_chats);
  }

  Future<List<Chat>> fetchChats() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return getChats();
  }

  Future<Chat?> getChatById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _chats.firstWhere((chat) => chat.id == id);
  }
}

// Provider for data service
final dataServiceProvider = Provider<DataService>((ref) {
  return DataService();
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
