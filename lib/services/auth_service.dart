import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Simulated user data model for authentication
class User {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final String? department;
  final String? year;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.department,
    this.year,
  });

  // Create a user from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'],
      department: json['department'],
      year: json['year'],
    );
  }

  // Convert user to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'department': department,
      'year': year,
    };
  }
}

// Authentication service to handle login, signup, and profile management
class AuthService {
  // Simulated storage for user data
  static final Map<String, User> _users = {};
  User? _currentUser;
  
  // Stream controller to broadcast authentication state changes
  final _authStateController = StreamController<User?>.broadcast();
  Stream<User?> get authStateChanges => _authStateController.stream;

  // Get current user
  User? get currentUser => _currentUser;

  // Initialize auth service and check for stored user credentials
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      
      if (userJson != null) {
        // Simulate user session from stored preferences
        _currentUser = User.fromJson({
          'id': prefs.getString('userId') ?? '',
          'email': prefs.getString('userEmail') ?? '',
          'name': prefs.getString('userName') ?? '',
          'avatar': prefs.getString('userAvatar'),
          'department': prefs.getString('userDepartment'),
          'year': prefs.getString('userYear'),
        });
        _authStateController.add(_currentUser);
      } else {
        _authStateController.add(null);
      }
    } catch (e) {
      print('Error initializing auth service: $e');
      _authStateController.add(null);
    }
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      // In a real app, this would validate against a real backend
      // For demo, just check if user exists in our simulated database
      final normalizedEmail = email.toLowerCase().trim();
      
      // For testing, allow any valid email/password combination
      // In a real app, this would verify credentials with a backend
      if (password.length >= 6) {
        // Create user if it doesn't exist (for testing only)
        if (!_users.containsKey(normalizedEmail)) {
          _users[normalizedEmail] = User(
            id: DateTime.now().millisecondsSinceEpoch.toString(), 
            email: normalizedEmail,
            name: normalizedEmail.split('@').first,
          );
        }
        
        _currentUser = _users[normalizedEmail];
        _saveUserToPrefs(_currentUser!);
        _authStateController.add(_currentUser);
        return _currentUser;
      } else {
        throw Exception('Invalid password');
      }
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<User?> signUp(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      final normalizedEmail = email.toLowerCase().trim();
      
      // In a real app, this would check if email already exists
      // For demo, just create a new user
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final newUser = User(
        id: userId,
        email: normalizedEmail,
        name: normalizedEmail.split('@').first, // Default name from email
      );
      
      _users[normalizedEmail] = newUser;
      _currentUser = newUser;
      _authStateController.add(_currentUser);
      
      return _currentUser;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<User?> updateProfile({
    required String name,
    String? avatarUrl,
    String? department,
    String? year,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      if (_currentUser == null) {
        throw Exception('No user is signed in');
      }
      
      // Update user with new profile data
      final updatedUser = User(
        id: _currentUser!.id,
        email: _currentUser!.email,
        name: name,
        avatar: avatarUrl ?? _currentUser!.avatar,
        department: department ?? _currentUser!.department,
        year: year ?? _currentUser!.year,
      );
      
      _users[_currentUser!.email] = updatedUser;
      _currentUser = updatedUser;
      _saveUserToPrefs(_currentUser!);
      _authStateController.add(_currentUser);
      
      return _currentUser;
    } catch (e) {
      print('Update profile error: $e');
      rethrow;
    }
  }

  // Sign out current user
  Future<void> signOut() async {
    try {
      _currentUser = null;
      
      // Clear stored preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('userId');
      await prefs.remove('userEmail');
      await prefs.remove('userName');
      await prefs.remove('userAvatar');
      await prefs.remove('userDepartment');
      await prefs.remove('userYear');
      
      _authStateController.add(null);
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Save user details to shared preferences
  Future<void> _saveUserToPrefs(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', 'true');
      await prefs.setString('userId', user.id);
      await prefs.setString('userEmail', user.email);
      await prefs.setString('userName', user.name);
      
      if (user.avatar != null) {
        await prefs.setString('userAvatar', user.avatar!);
      }
      
      if (user.department != null) {
        await prefs.setString('userDepartment', user.department!);
      }
      
      if (user.year != null) {
        await prefs.setString('userYear', user.year!);
      }
    } catch (e) {
      print('Error saving user to prefs: $e');
    }
  }

  // Dispose method to clean up resources
  void dispose() {
    _authStateController.close();
  }
}

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final authService = AuthService();
  ref.onDispose(() => authService.dispose());
  return authService;
});

// Provider for current user
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  // Initialize auth service
  authService.initialize();
  return authService.authStateChanges;
});

// Provider for authentication state
final authStateProvider = Provider<bool>((ref) {
  final userAsyncValue = ref.watch(currentUserProvider);
  return userAsyncValue.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});
