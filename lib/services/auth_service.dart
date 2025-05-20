import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_community_app/models/user.dart';
import 'package:flutter_community_app/services/api_service.dart';

// Authentication service to handle login, signup, and profile management
class AuthService {
  final ApiService _apiService;
  User? _currentUser;

  // Stream controller to broadcast authentication state changes
  final _authStateController = StreamController<User?>.broadcast();
  Stream<User?> get authStateChanges => _authStateController.stream;

  // Get current user
  User? get currentUser => _currentUser;

  // Check if profile is complete
  bool get isProfileComplete {
    if (_currentUser == null) return false;
    return _currentUser!.name.isNotEmpty &&
        _currentUser!.department != null &&
        _currentUser!.year != null;
  }

  // Check if user is admin
  bool get isAdmin {
    if (_currentUser == null) return false;
    return _currentUser!.isAdmin;
  }

  AuthService(this._apiService);

  // Initialize auth service and check for stored user credentials
  Future<void> initialize() async {
    try {
      await _apiService.initialize();

      // If we have a token, try to get the current user
      if (_apiService.token != null) {
        try {
          final userData = await _apiService.getCurrentUser();
          _currentUser = User.fromJson(userData['user']);
          _authStateController.add(_currentUser);
        } catch (e) {
          print('Error getting current user: $e');
          await _apiService.clearToken();
          _authStateController.add(null);
        }
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
    try {
      final response = await _apiService.login(email, password);
      final userData = response['user'];

      _currentUser = User.fromJson(userData);
      _authStateController.add(_currentUser);

      return _currentUser;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<User?> signUp(String email, String password, {String? name}) async {
    try {
      final response = await _apiService.register(email, password, name);
      final userData = response['user'];

      _currentUser = User.fromJson(userData);
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
    try {
      final response = await _apiService.updateProfile(
        name: name,
        avatarUrl: avatarUrl,
        department: department,
        year: year,
      );

      final userData = response['user'];
      _currentUser = User.fromJson(userData);
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
      await _apiService.clearToken();
      _currentUser = null;
      _authStateController.add(null);
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Dispose method to clean up resources
  void dispose() {
    _authStateController.close();
  }
}

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final authService = AuthService(apiService);
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

// Provider for profile completion state
final profileCompleteProvider = Provider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isProfileComplete;
});

// Provider for admin status
final isAdminProvider = Provider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isAdmin;
});
