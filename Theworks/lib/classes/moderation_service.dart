class ModerationService {
  // A basic list of prohibited words. In a production app, this should be more comprehensive or use an external API.
  static final List<String> _badWords = [
    'damn',
    'hell',
    'stupid',
    'idiot',
    'fuck',
    'shit',
    'bitch',
    'asshole',
    'cunt',
    'dick',
    'pussy',
    'bastard',
    'nigger',
    'faggot',
    // Add more as needed
  ];

  static bool containsProfanity(String text) {
    final lowerText = text.toLowerCase();
    for (final word in _badWords) {
      // Check for whole words to avoid false positives (e.g., "class" containing "ass")
      // using regex \bWORD\b
      final RegExp regex = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
      if (regex.hasMatch(lowerText)) {
        return true;
      }
    }
    return false;
  }
}
