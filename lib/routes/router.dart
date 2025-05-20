import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_community_app/routes/auth_redirect.dart';
import 'package:flutter_community_app/screens/auth/login_screen.dart';
import 'package:flutter_community_app/screens/auth/signup_screen.dart';
import 'package:flutter_community_app/screens/auth/profile_setup_screen.dart';
import 'package:flutter_community_app/screens/home/home_screen.dart';
import 'package:flutter_community_app/screens/forums/forum_screen.dart';
import 'package:flutter_community_app/screens/notes/notes_screen.dart';
import 'package:flutter_community_app/screens/papers/papers_screen.dart';
import 'package:flutter_community_app/screens/skills/skills_screen.dart';
import 'package:flutter_community_app/screens/skills/skill_detail_screen.dart';
import 'package:flutter_community_app/screens/messages/messages_screen.dart';
import 'package:flutter_community_app/screens/messages/chat_screen.dart';
import 'package:flutter_community_app/screens/splash_screen.dart';
import 'package:flutter_community_app/screens/profile/profile_screen.dart';
import 'package:flutter_community_app/screens/admin/admin_skills_screen.dart';
import 'package:flutter_community_app/services/auth_service.dart';
import 'package:flutter_community_app/providers/app_state_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Watch the authentication state and app initialization state
  final appState = ref.watch(appStateProvider);
  final isAuthenticated = ref.watch(authStateProvider);
  final authService = ref.watch(authServiceProvider);

  // Create redirect function with current state values
  final redirectFunction = (BuildContext context, GoRouterState state) {
    final isOnSplash = state.matchedLocation == '/';
    final isOnAuthPage = ['/login', '/signup'].contains(state.matchedLocation);
    final isOnProfileSetup = state.matchedLocation == '/profile-setup';

    // If app is not initialized, allow splash screen
    if (!appState.isInitialized && isOnSplash) {
      return null;
    }

    // Force redirect to splash while initializing
    if (!appState.isInitialized && !isOnSplash) {
      return '/';
    }

    // If authenticated but profile not complete, redirect to profile setup
    if (isAuthenticated && !authService.isProfileComplete && !isOnProfileSetup) {
      return '/profile-setup';
    }

    // Redirect authenticated users away from auth pages
    if (isAuthenticated && isOnAuthPage) {
      return authService.isProfileComplete ? '/home' : '/profile-setup';
    }

    // Redirect unauthenticated users to login except for auth pages
    if (!isAuthenticated && !isOnAuthPage && !isOnSplash) {
      return '/login';
    }

    // Redirect from splash to login when initialized
    if (isInitialized && isOnSplash) {
      return isAuthenticated ?
      (authService.isProfileComplete ? '/home' : '/profile-setup') :
      '/login';
    }

    // Allow the navigation
    return null;
  };

  return GoRouter(
    initialLocation: '/',
    redirect: redirectFunction,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/forum/:departmentId',
        builder: (context, state) {
          final departmentId = state.pathParameters['departmentId'] ?? '';
          return ForumScreen(departmentId: departmentId);
        },
      ),
      GoRoute(
        path: '/notes',
        builder: (context, state) => const NotesScreen(),
      ),
      GoRoute(
        path: '/papers',
        builder: (context, state) => const PapersScreen(),
      ),
      GoRoute(
        path: '/skills',
        builder: (context, state) => const SkillsScreen(),
      ),
      GoRoute(
        path: '/skills/:skillId',
        builder: (context, state) {
          final skillId = state.pathParameters['skillId'] ?? '';
          return SkillDetailScreen(skillId: skillId);
        },
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MessagesScreen(),
      ),
      GoRoute(
        path: '/chat/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';
          return ChatScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/admin/skills',
        builder: (context, state) => const AdminSkillsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});
