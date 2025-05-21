import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_community_app/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:http/http.dart' as http;

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  // Initialize Supabase
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
      debug: true,
    );
    print('***** Supabase init completed ${Supabase.instance}');
  }

  // Check if user is authenticated
  bool get isAuthenticated => _client.auth.currentSession != null;

  // Get current user ID
  String? get currentUserId => _client.auth.currentUser?.id;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );

    // Create profile immediately after signup
    if (response.user != null) {
      try {
        await _client.from('profiles').upsert({
          'id': response.user!.id,
          'name': data?['name'] ?? email.split('@')[0],
          'email': email,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('Profile created during signup');
      } catch (e) {
        print('Error creating profile during signup: $e');
      }
    }

    return response;
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Get user profile
  Future<User?> getUserProfile() async {
    try {
      if (currentUserId == null) {
        print('No current user ID');
        return null;
      }

      print('Fetching profile for user ID: $currentUserId');

      // First try to get the profile
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', currentUserId)
          .single();

      print('Profile response: $response');

      if (response != null) {
        return User(
          id: response['id'],
          email: response['email'],
          name: response['name'] ?? '',
          avatarUrl: response['avatar_url'],
          department: response['department'],
          year: response['year'],
          createdAt: DateTime.parse(response['created_at']),
          updatedAt: DateTime.parse(response['updated_at']),
        );
      }
    } catch (e) {
      print('Error getting user profile: $e');

      // If profile doesn't exist, try to create it from auth data
      try {
        final authUser = _client.auth.currentUser;
        if (authUser != null) {
          final now = DateTime.now().toIso8601String();

          // Create a basic profile
          await _client.from('profiles').upsert({
            'id': authUser.id,
            'name': authUser.userMetadata?['name'] ?? authUser.email?.split('@')[0] ?? 'User',
            'email': authUser.email ?? '',
            'created_at': now,
            'updated_at': now,
          });

          print('Created profile from auth data');

          // Return a basic user object
          return User(
            id: authUser.id,
            email: authUser.email ?? '',
            name: authUser.userMetadata?['name'] ?? authUser.email?.split('@')[0] ?? 'User',
            avatarUrl: null,
            createdAt: DateTime.parse(now),
            updatedAt: DateTime.parse(now),
          );
        }
      } catch (createError) {
        print('Error creating profile from auth data: $createError');
      }
    }

    return null;
  }

  // Update user profile
  Future<User?> updateUserProfile({
    required String name,
    String? avatarUrl,
    String? department,
    String? year,
  }) async {
    try {
      if (currentUserId == null) return null;

      final now = DateTime.now().toIso8601String();

      final data = {
        'name': name,
        'updated_at': now,
      };

      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
      if (department != null) data['department'] = department;
      if (year != null) data['year'] = year;

      await _client
          .from('profiles')
          .update(data)
          .eq('id', currentUserId);

      return await getUserProfile();
    } catch (e) {
      print('Error updating user profile: $e');
      return null;
    }
  }

  // Upload avatar image
  Future<String?> uploadAvatar(String filePath, String fileName) async {
    try {
      if (currentUserId == null) return null;

      final fileExt = path.extension(fileName);
      final fileId = '${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final storagePath = 'avatars/$currentUserId/$fileId';

      if (kIsWeb) {
        // For web, we need to handle file upload differently
        final response = await http.get(Uri.parse(filePath));
        final bytes = response.bodyBytes;

        await _client.storage
            .from('user-content')
            .uploadBinary(storagePath, bytes);
      } else {
        // For mobile
        final file = File(filePath);
        final bytes = await file.readAsBytes();

        await _client.storage
            .from('user-content')
            .uploadBinary(storagePath, bytes);
      }

      final url = _client.storage
          .from('user-content')
          .getPublicUrl(storagePath);

      return url;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }
}

// Provider for Supabase client
final supabaseClientProvider = riverpod.Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Provider for Supabase service
final supabaseServiceProvider = riverpod.Provider<SupabaseService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseService(client);
});
