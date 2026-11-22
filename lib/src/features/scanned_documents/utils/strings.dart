const String ocrInstruction = 'Transcribe this handwritten page to Markdown.';

final RegExp _markdownFenceRegex = RegExp(
  r'^```(?:markdown|md)?[ \t]*\n([\s\S]*?)\n?```\s*$',
);
final RegExp _leadingOpenFenceRegex = RegExp(r'^```(?:markdown|md)?[ \t]*\n');
final RegExp _trailingCloseFenceRegex = RegExp(r'\n?```\s*$');
final RegExp _chatTemplateLeakRegex = RegExp(
  r'<\|(?:im_start|im_end|endoftext)\|>',
);
final RegExp _leadingWhitespaceRegex = RegExp(r'^\s+');
final RegExp _excessSpacesRegex = RegExp(r' {9,}');
final RegExp _excessNewlinesRegex = RegExp(r'\n{4,}');

// Degenerate Markdown patterns to catch during inference:
final RegExp _degenerateMdCharFloodRegex = RegExp(r'([-=*_#|`~])\1{19,}');
final RegExp _emptyListSpamRegex = RegExp(
  r'(?:^(?:[-*+]|\d+\.)[ \t]*$\n?){4,}',
  multiLine: true,
);
final RegExp _emptyHeadingSpamRegex = RegExp(
  r'(?:^#{1,6}[ \t]*$\n?){3,}',
  multiLine: true,
);
final RegExp _emptyTableRowSpamRegex = RegExp(
  r'(?:^\|(?:[ \t:-]*\|)+\s*$\n?){4,}',
  multiLine: true,
);
final RegExp _repeatedLinesRegex = RegExp(
  r'^(?!\s*$)(.+)$(?:\r?\n\1$){3,}',
  multiLine: true,
);

/// Strips accidental outer ```markdown ... ``` wrappers if the model emits them,
/// truncates leaked chat-template tokens, and returns raw Markdown text.
String cleanOcrMarkdown(String text) {
  var cleaned = text.trim();

  if (cleaned.isEmpty) {
    return '';
  }

  final leakMatch = _chatTemplateLeakRegex.firstMatch(cleaned);

  if (leakMatch != null) {
    cleaned = cleaned.substring(0, leakMatch.start).trim();
  }

  final fullMatch = _markdownFenceRegex.firstMatch(cleaned);

  if (fullMatch != null) {
    return fullMatch.group(1)!.trim();
  }

  if (_leadingOpenFenceRegex.hasMatch(cleaned)) {
    cleaned = cleaned
        .replaceFirst(_leadingOpenFenceRegex, '')
        .replaceFirst(_trailingCloseFenceRegex, '')
        .trim();
  }

  return cleaned;
}

/// Clamps consecutive spaces to 8 (preserving Markdown indentation & 2-space
/// line breaks) and consecutive newlines to 3, and strips leading whitespace.
String clampMarkdownWhitespace(String text) {
  var result = text.replaceFirst(_leadingWhitespaceRegex, '');
  result = result.replaceAll(_excessSpacesRegex, '        ');
  result = result.replaceAll(_excessNewlinesRegex, '\n\n\n');

  return result;
}

/// Returns `true` when the rolling Markdown tail is stuck in a degenerate loop:
/// - 40+ spaces or 10+ newlines
/// - 20+ repeated Markdown symbols (`---`, `|||`, `###`, `***`, ```` ``` ````)
/// - 4+ empty bullet/numbered list items (`- \n- \n- \n- `)
/// - 3+ empty Markdown headings (`## \n## \n## `)
/// - 4+ empty Markdown table rows (`| | |\n| | |`)
/// - 4 consecutive identical non-empty lines
bool isRunawayMarkdown(String tail) {
  if (tail.contains(' ' * 40)) {
    return true;
  }

  if (tail.contains('\n' * 10)) {
    return true;
  }

  if (_degenerateMdCharFloodRegex.hasMatch(tail)) {
    return true;
  }

  if (_emptyListSpamRegex.hasMatch(tail)) {
    return true;
  }

  if (_emptyHeadingSpamRegex.hasMatch(tail)) {
    return true;
  }

  if (_emptyTableRowSpamRegex.hasMatch(tail)) {
    return true;
  }

  if (_repeatedLinesRegex.hasMatch(tail)) {
    return true;
  }

  return false;
}

/// Guards a live Markdown token stream with whitespace clamping, chat-marker
/// cutoff, and runaway Markdown loop termination.
Stream<String> guardOcrMarkdownStream(
  Stream<String> source, {
  String initialText = '',
  int windowSize = 400,
}) async* {
  final sanitizedInitial = clampMarkdownWhitespace(initialText);
  final rawTail = StringBuffer(
    sanitizedInitial.length > windowSize
        ? sanitizedInitial.substring(sanitizedInitial.length - windowSize)
        : sanitizedInitial,
  );

  var hasContent = sanitizedInitial.isNotEmpty;
  var trailingSpaces = _trailingCount(sanitizedInitial, ' ');
  var trailingNewlines = _trailingCount(sanitizedInitial, '\n');

  await for (final chunk in source) {
    if (chunk.isEmpty) {
      continue;
    }

    final leakMatch = _chatTemplateLeakRegex.firstMatch(chunk);
    final usable = leakMatch != null
        ? chunk.substring(0, leakMatch.start)
        : chunk;

    if (usable.isNotEmpty) {
      // Check runaway on the unclamped rolling tail so 40+ spaces or 10+
      // newlines still trigger even though emitted text is clamped to 8 / 3.
      rawTail.write(usable);
      var tail = rawTail.toString();
      if (tail.length > windowSize) {
        tail = tail.substring(tail.length - windowSize);
        rawTail
          ..clear()
          ..write(tail);
      }

      if (isRunawayMarkdown(tail)) {
        break;
      }

      final out = StringBuffer();
      for (var i = 0; i < usable.length; i++) {
        final ch = usable[i];

        if (!hasContent) {
          if (ch == ' ' || ch == '\n' || ch == '\r' || ch == '\t') {
            continue;
          }
          hasContent = true;
        }

        if (ch == ' ') {
          trailingNewlines = 0;
          if (trailingSpaces >= 8) continue;
          trailingSpaces++;
          out.write(ch);
        } else if (ch == '\n') {
          trailingSpaces = 0;
          if (trailingNewlines >= 3) continue;
          trailingNewlines++;
          out.write(ch);
        } else {
          trailingSpaces = 0;
          trailingNewlines = 0;
          out.write(ch);
        }
      }

      final delta = out.toString();
      if (delta.isNotEmpty) {
        yield delta;
      }
    }

    if (leakMatch != null) {
      break;
    }
  }
}

int _trailingCount(String text, String char) {
  var count = 0;
  for (var i = text.length - 1; i >= 0 && text[i] == char; i--) {
    count++;
  }
  return count;
}

final RegExp _whitespaceRegex = RegExp(r'\s');
final RegExp _wordSplitRegex = RegExp(r'\s+');

/// Trims any trailing incomplete word so LLM generation resumes cleanly on a
/// natural word boundary without subword artifacts.
String preparePrefill(String? rawPartial) {
  if (rawPartial == null || rawPartial.isEmpty) {
    return '';
  }

  final lastWhitespace = rawPartial.lastIndexOf(_whitespaceRegex);
  if (lastWhitespace <= 0) {
    return '';
  }

  return rawPartial.substring(0, lastWhitespace + 1);
}

/// Counts whitespace-delimited words in [text].
int countWords(String text) {
  if (text.isEmpty) {
    return 0;
  }

  return text.split(_wordSplitRegex).where((w) => w.isNotEmpty).length;
}

/// Estimates reading duration in milliseconds for [wordCount] at
/// [wordsPerMinute].
int estimateReadTimeMs(int wordCount, {int wordsPerMinute = 200}) {
  if (wordCount <= 0 || wordsPerMinute <= 0) {
    return 0;
  }

  return ((wordCount / wordsPerMinute) * 60 * 1000).round();
}
