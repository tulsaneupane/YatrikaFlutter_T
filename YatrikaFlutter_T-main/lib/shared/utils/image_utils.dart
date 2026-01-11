class ImageUtils {
  static String sanitizeUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    // If it's already a full URL, just return it
    if (url.startsWith('http')) return url;
    // Otherwise, let ApiClient handle the ngrok prefixing
    return url; 
  }
}