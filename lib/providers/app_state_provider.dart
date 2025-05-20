import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_community_app/services/auth_service.dart';

// Manage application state
class AppState {
  final bool isInitialized;
  final bool isDarkMode;
  
  AppState({
    this.isInitialized = false,
    this.isDarkMode = false,
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
  
  AppStateNotifier(this._authService) : super(AppState()) {
    _initialize();
  }
  
  // Initialize app state and services
  Future<void> _initialize() async {
    // Simulate app initialization delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Initialize auth service
    await _authService.initialize();
    
    // Mark app as initialized
    state = state.copyWith(isInitialized: true);
  }
  
  // Toggle dark mode
  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }
}

// Provider for app state
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AppStateNotifier(authService);
});

// Provider for dark mode status
final darkModeProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isDarkMode;
});
