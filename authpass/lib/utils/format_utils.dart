class FormatUtils {
  /// To keep things secure, like URLs we just log the first few characters.
  static String maxLength(String string, int maxLength, {String ellipsis = '…'}) {
    if (string.length > maxLength) {
      return '${string.substring(0, maxLength)}$ellipsis';
    }
    return string;
  }

  static String anonymizeUrl(String potentialUrl) => maxLength(potentialUrl, 15);
}