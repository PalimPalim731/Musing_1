// utils/text_utils.dart

/// Utility functions for text manipulation
class TextUtils {
  /// Truncates text to a maximum length and adds ellipsis if needed
  static String truncateWithEllipsis(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
}