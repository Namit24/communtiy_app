import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_community_app/models/user.dart';
import 'package:flutter_community_app/services/supabase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class AuthResult {
  final bool success;
  final User? user;
  final String? errorMessage;

  AuthResult({
    required this.success,
    this.user,
    this.errorMessage,
  });
}

class AuthService {
  final SupabaseService _supabaseService;
  User? _currentUser;
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();
  bool _isAuthenticated = false;

  AuthService(this._supabaseService) {
    // Initialize the auth state
    initialize();
  }

  // Initialize auth state and listen for changes
  Future<void> initialize() async {
    try {
      // Check if user is already authenticated
      if (_supabaseService.isAuthenticated) {
        _currentUser = await _supabaseService.getUserProfile();
        _isAuthenticated = _currentUser != null;
        _authStateController.add(_currentUser);
        print('Auth initialized: isAuthenticated=$_isAuthenticated, user=${_currentUser?.name}');

        // Force update the auth state provider
        if (_isAuthenticated) {
          final container = riverpod.ProviderContainer();
          container.read(authStateProvider.notifier).state = true;
        }
      } else {
        _isAuthenticated = false;
        _authStateController.add(null);
        print('Auth initialized: not authenticated');
      }

      // Listen for auth state changes
      Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
        final AuthChangeEvent event = data.event;
        print('**** onAuthStateChange: $event');

        if (event == AuthChangeEvent.signedIn) {
          // Add a delay to allow the database trigger to create the profile
          await Future.delayed(const Duration(milliseconds: 500));
          try {
            _currentUser = await _supabaseService.getUserProfile();
            _isAuthenticated = _currentUser != null;
            print('Auth state updated: isAuthenticated=$_isAuthenticated, user=${_currentUser?.name}');
            _authStateController.add(_currentUser);

            // Force update the auth state provider
            if (_isAuthenticated) {
              final container = riverpod.ProviderContainer();
              container.read(authStateProvider.notifier).state = true;
            }
          } catch (e) {
            print('Error updating auth state after sign in: $e');
            _isAuthenticated = false;
            _authStateController.add(null);
          }
        } else if (event == AuthChangeEvent.signedOut) {
          _currentUser = null;
          _isAuthenticated = false;
          _authStateController.add(null);
          print('Auth state updated: signed out');

          // Force update the auth state provider
          final container = riverpod.ProviderContainer();
          container.read(authStateProvider.notifier).state = false;
        }
      });
    } catch (e) {
      print('Error initializing auth service: $e');
      _isAuthenticated = false;
      _authStateController.add(null);
    }
  }

  // Get current user
  User? get currentUser => _currentUser;

  // Get auth state stream
  Stream<User?> get authStateChanges => _authStateController.stream;

  // Check if user is authenticated
  bool get isAuthenticated => _isAuthenticated;

  // Sign in with email and password
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Add a delay to ensure profile is available
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          _currentUser = await _supabaseService.getUserProfile();
          _isAuthenticated = _currentUser != null;
          print('Sign in successful: isAuthenticated=$_isAuthenticated, user=${_currentUser?.name}');
          _authStateController.add(_currentUser);

          return AuthResult(
            success: true,
            user: _currentUser,
          );
        } catch (e) {
          print('Error getting profile after sign in: $e');
          _isAuthenticated = false;
          _authStateController.add(null);
          return AuthResult(
            success: false,
            errorMessage: 'Error getting user profile: $e',
          );
        }
      } else {
        _isAuthenticated = false;
        return AuthResult(
          success: false,
          errorMessage: 'Invalid email or password',
        );
      }
    } catch (e) {
      print('Sign in error: $e');
      _isAuthenticated = false;
      return AuthResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Register with email and password
  Future<AuthResult> signUpWithEmail(String email, String password, {String? name}) async {
    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        data: {
          'name': name ?? email.split('@')[0],
        },
      );

      if (response.user != null) {
        // The profile will be created by the database trigger
        // Add a delay to ensure the trigger has time to execute
        await Future.delayed(const Duration(milliseconds: 1000));

        try {
          _currentUser = await _supabaseService.getUserProfile();
          if (_currentUser == null) {
            // If profile still doesn't exist, create a basic user object
            final now = DateTime.now();
            _currentUser = User(
              id: response.user!.id,
              name: name ?? email.split('@')[0],
              email: email,
              avatarUrl: null,
              createdAt: now,
              updatedAt: now,
            );
          }
          _isAuthenticated = true;
          print('Sign up successful: isAuthenticated=$_isAuthenticated, user=${_currentUser?.name}');
          _authStateController.add(_currentUser);
        } catch (profileError) {
          print('Error getting profile after signup: $profileError');
          // Create a basic user object from auth data
          final now = DateTime.now();
          _currentUser = User(
            id: response.user!.id,
            name: name ?? email.split('@')[0],
            email: email,
            avatarUrl: null,
            createdAt: now,
            updatedAt: now,
          );
          _isAuthenticated = true;
          _authStateController.add(_currentUser);
        }

        return AuthResult(
          success: true,
          user: _currentUser,
        );
      } else {
        _isAuthenticated = false;
        return AuthResult(
          success: false,
          errorMessage: 'Failed to create account',
        );
      }
    } catch (e) {
      print('Sign up error: $e');
      _isAuthenticated = false;
      return AuthResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Update user profile
  Future<AuthResult> updateProfile({
    required String name,
    String? avatarUrl,
    String? department,
    String? year,
  }) async {
    try {
      final updatedUser = await _supabaseService.updateUserProfile(
        name: name,
        avatarUrl: avatarUrl,
        department: department,
        year: year,
      );

      if (updatedUser != null) {
        _currentUser = updatedUser;
        _isAuthenticated = true;
        _authStateController.add(_currentUser);

        return AuthResult(
          success: true,
          user: _currentUser,
        );
      } else {
        return AuthResult(
          success: false,
          errorMessage: 'Failed to update profile',
        );
      }
    } catch (e) {
      print('Update profile error: $e');
      return AuthResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Upload avatar image
  Future<String?> uploadAvatar(String filePath, String fileName) async {
    try {
      return await _supabaseService.uploadAvatar(filePath, fileName);
    } catch (e) {
      print('Upload avatar error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabaseService.signOut();
    _currentUser = null;
    _isAuthenticated = false;
    _authStateController.add(null);
    print('User signed out');
  }

  // Dispose
  void dispose() {
    _authStateController.close();
  }
}

// Provider for auth service
final authServiceProvider = riverpod.Provider<AuthService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AuthService(supabaseService);
});

// Provider for auth state
final authStateProvider = riverpod.StateProvider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  final isAuth = authService.isAuthenticated;
  print('authStateProvider: isAuthenticated=$isAuth');
  return isAuth;
});

// Provider for current user
final currentUserProvider = riverpod.StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});
