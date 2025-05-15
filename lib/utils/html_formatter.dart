import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;

/// A utility class for formatting HTML content
class HtmlFormatter {
  /// Removes HTML tags from a string and decodes HTML entities
  static String stripHtml(String? htmlString) {
    if (htmlString == null || htmlString.isEmpty) {
      return '';
    }

    try {
      // Parse the HTML
      dom.Document document = htmlparser.parse(htmlString);
      
      // Get the text content
      String parsedText = document.body?.text ?? '';
      
      // Decode HTML entities
      String decodedText = _decodeHtmlEntities(parsedText);
      
      // Remove extra whitespace
      return decodedText.trim().replaceAll(RegExp(r'\s+'), ' ');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error parsing HTML: $e');
      }
      // Fallback to a simpler approach if parsing fails
      return htmlString
          .replaceAll(RegExp(r'<[^>]*>'), '')  // Remove HTML tags
          .replaceAll('&amp;', '&')            // Replace common HTML entities
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"')
          .replaceAll('&#39;', "'")
          .replaceAll('&nbsp;', ' ')
          .trim();
    }
  }

  /// Decodes HTML entities in a string
  static String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&ndash;', '–')
        .replaceAll('&mdash;', '—')
        .replaceAll('&lsquo;', ''')
        .replaceAll('&rsquo;', ''')
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&bull;', '•')
        .replaceAll('&hellip;', '…');
  }
}
