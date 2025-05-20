import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

// Utility to check platform support for various features
class PlatformChecker {
  // Check if we're running on web
  static bool get isWeb => kIsWeb;
  
  // Check if we're running on mobile (Android or iOS)
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
  
  // Check if platform supports file_picker properly
  static bool get supportsFilePicker {
    // On web, file picker has some limitations but works
    if (kIsWeb) return true;
    
    // Works well on mobile
    if (Platform.isAndroid || Platform.isIOS) return true;
    
    // May have limitations on other platforms
    return false;
  }
  
  // Get platform name for debugging
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isFuchsia) return 'Fuchsia';
    return 'Unknown';
  }
}
