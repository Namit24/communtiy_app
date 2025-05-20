import 'package:flutter/foundation.dart' show kIsWeb;

// Utility functions for web platform
class WebUtils {
  // Handles browser compatibility for images
  static dynamic getImageProvider(String? imageUrl) {
    if (imageUrl == null) {
      return null;
    }
    
    if (kIsWeb) {
      // For web, use NetworkImage even for local files (since file paths in web are URLs)
      return NetworkImage(imageUrl);
    } else {
      // For mobile, check if it's a remote URL or local file
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        return NetworkImage(imageUrl);
      } else {
        return AssetImage(imageUrl);
      }
    }
  }
  
  // Handles file picking compatibility issues
  static bool canUseAdvancedFilePicker() {
    // Some features might not work in certain browsers
    return !kIsWeb || (kIsWeb && isChromeBrowser());
  }
  
  // Basic detection of Chrome browser (would need to be refined in production)
  static bool isChromeBrowser() {
    if (!kIsWeb) return false;
    
    // In a real app, you'd use a more sophisticated approach
    // This is a simple placeholder that assumes Chrome by default
    return true;
  }
  
  // Check if we're running in a mobile browser
  static bool isMobileBrowser() {
    if (!kIsWeb) return false;
    
    // In a real app, you'd check the user agent or use a package
    // This is just a placeholder
    return false;
  }
}
