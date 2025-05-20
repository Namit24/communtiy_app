import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_community_app/models/user.dart';

class ApiService {
  // Base URL for API
  final String baseUrl;
  String? _token;

  ApiService({required this.baseUrl});

  // Initialize and load token if available
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Get auth token
  String? get token => _token;

  // Set auth token
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear auth token
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get headers with auth token
  Map<String, String> get headers {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // Register user
  Future<Map<String, dynamic>> register(String email, String password, String? name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      await setToken(data['token']);
      return data;
    } else {
      throw Exception(data['error'] ?? 'Registration failed');
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await setToken(data['token']);
      return data;
    } else {
      throw Exception(data['error'] ?? 'Login failed');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? department,
    String? year,
    String? avatarUrl,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/auth/profile'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'department': department,
        'year': year,
        'avatarUrl': avatarUrl,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Profile update failed');
    }
  }

  // Fetch notes
  Future<List<dynamic>> getNotes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/notes'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to fetch notes');
    }
  }

  // Create note
  Future<Map<String, dynamic>> createNote({
    required String title,
    required String subject,
    required String fileUrl,
    required String fileSize,
    required String fileType,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/notes'),
      headers: headers,
      body: jsonEncode({
        'title': title,
        'subject': subject,
        'fileUrl': fileUrl,
        'fileSize': fileSize,
        'fileType': fileType,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Failed to create note');
    }
  }

  // Fetch papers
  Future<List<dynamic>> getPapers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/papers'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to fetch papers');
    }
  }

  // Create paper
  Future<Map<String, dynamic>> createPaper({
    required String title,
    required String subject,
    required String year,
    required String examType,
    required String fileUrl,
    required String fileSize,
    required String fileType,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/papers'),
      headers: headers,
      body: jsonEncode({
        'title': title,
        'subject': subject,
        'year': year,
        'examType': examType,
        'fileUrl': fileUrl,
        'fileSize': fileSize,
        'fileType': fileType,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Failed to create paper');
    }
  }

  // Fetch skills
  Future<List<dynamic>> getSkills() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/skills'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to fetch skills');
    }
  }

  // Fetch forum posts
  Future<List<dynamic>> getForumPosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/forum-posts'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to fetch forum posts');
    }
  }

  // Create forum post
  Future<Map<String, dynamic>> createForumPost(String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/forum-posts'),
      headers: headers,
      body: jsonEncode({
        'content': content,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Failed to create forum post');
    }
  }

  // Fetch messages (conversations)
  Future<List<dynamic>> getConversations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/messages'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to fetch conversations');
    }
  }

  // Fetch messages with a specific user
  Future<List<dynamic>> getMessages(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/messages/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to fetch messages');
    }
  }

  // Send message
  Future<Map<String, dynamic>> sendMessage(String receiverId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/messages'),
      headers: headers,
      body: jsonEncode({
        'receiverId': receiverId,
        'content': content,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Failed to send message');
    }
  }
}

// Provider for API service
final apiServiceProvider = Provider<ApiService>((ref) {
  // Use localhost for development, change for production
  return ApiService(baseUrl: 'http://localhost:3000');
});
