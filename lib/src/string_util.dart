class StringUtil {
  static int fuzzyScore(final String term, final String query) {
    final String termLower = term.toLowerCase();
    final String queryLower = query.toLowerCase();

    int score = 0;
    int termIndex = 0;

    int previousMatchingCharacterIndex = -0x8000000000000000;

    for (int queryIndex = 0; queryIndex < queryLower.length; queryIndex++) {
      final String queryChar = queryLower[queryIndex];

      bool foundMatch = false;
      for (; termIndex < termLower.length && !foundMatch; termIndex++) {
        final String termChar = termLower[termIndex];

        if (queryChar == termChar) {
          score++;

          if (previousMatchingCharacterIndex + 1 == termIndex) {
            score += 2;
          }

          previousMatchingCharacterIndex = termIndex;

          foundMatch = true;
        }
      }
    }
    return score;
  }
}

extension Similiarity on String {
  int fuzzyScore(final String query) => StringUtil.fuzzyScore(this, query);
}
