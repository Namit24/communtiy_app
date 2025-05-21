import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_community_app/services/auth_service.dart';

// Provider for dark mode state
final darkModeProvider = StateProvider<bool>((ref) => false);

// App state class
class AppState {
  final bool isInitialized;
  final bool isDarkMode;

  AppState({
    required this.isInitialized,
    required this.isDarkMode,
  });

  AppState copyWith({
    bool? isInitialized,
    bool? isDarkMode,
  }) {
    return AppState(
      isInitialized: isInitialized ?? this.isInitialized,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

// App state notifier
class AppStateNotifier extends StateNotifier<AppState> {
  final AuthService _authService;

  AppStateNotifier(this._authService) : super(AppState(isInitialized: false, isDarkMode: false)) {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize auth service
      await _authService.initialize();

      // Update state to indicate initialization is complete
      state = state.copyWith(isInitialized: true);
      print('App initialization complete');
    } catch (e) {
      print('Error initializing app: $e');
      // Still mark as initialized to avoid getting stuck
      state = state.copyWith(isInitialized: true);
    }
  }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }
}

// Provider for app state
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AppStateNotifier(authService);
});
