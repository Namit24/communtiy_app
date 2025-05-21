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
    // Get the current path
    final String path = state.matchedLocation;

    // Print debug information
    print('Auth redirect: path=$path, isInitialized=$isInitialized, isAuthenticated=$isAuthenticated');

    // If the app is not initialized yet, don't redirect from splash
    if (!isInitialized && path == '/') {
      print('App not initialized, allowing splash screen');
      return null;
    }

    // Force redirect to splash while initializing
    if (!isInitialized && path != '/') {
      print('App not initialized, redirecting to splash');
      return '/';
    }

    // If the user is authenticated
    if (isAuthenticated) {
      // If they're trying to access auth screens, redirect to home
      if (path == '/login' || path == '/signup' || path == '/' || path == '/profile-setup') {
        print('Redirecting authenticated user to /home');
        return '/home';
      }
      // Otherwise, allow access to the requested page
      return null;
    } else {
      // If not authenticated and trying to access protected routes
      if (path != '/login' && path != '/signup' && path != '/' && path != '/profile-setup') {
        print('Redirecting unauthenticated user to /login');
        return '/login';
      }

      // Redirect from splash to login when initialized
      if (isInitialized && path == '/') {
        print('App initialized, redirecting from splash to login');
        return '/login';
      }

      // Otherwise, allow access to auth screens
      return null;
    }
  };
}
