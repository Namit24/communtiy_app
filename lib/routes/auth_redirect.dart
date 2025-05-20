import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Define a redirect function type that matches GoRouter's requirements
typedef RedirectFunction = String? Function(BuildContext context, GoRouterState state);

// Create a function that generates a redirect function with closure access to needed values
RedirectFunction createRedirectFunction({
  required bool isInitialized,
  required bool isAuthenticated,
}) {
  return (BuildContext context, GoRouterState state) {
    final isOnSplash = state.matchedLocation == '/';
    final isOnAuthPage = ['/login', '/signup', '/profile-setup'].contains(state.matchedLocation);

    // If app is not initialized, allow splash screen
    if (!isInitialized && isOnSplash) {
      return null;
    }

    // Force redirect to splash while initializing
    if (!isInitialized && !isOnSplash) {
      return '/';
    }

    // Redirect authenticated users away from auth pages
    if (isAuthenticated && isOnAuthPage) {
      return '/home';
    }

    // Redirect unauthenticated users to login except for auth pages
    if (!isAuthenticated && !isOnAuthPage && !isOnSplash) {
      return '/login';
    }

    // Redirect from splash to login when initialized
    if (isInitialized && isOnSplash) {
      return isAuthenticated ? '/home' : '/login';
    }

    // Allow the navigation
    return null;
  };
}
