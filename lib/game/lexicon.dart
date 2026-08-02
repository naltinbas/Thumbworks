import 'words.dart';

/// The words the game knows, and the prefixes worth following.
///
/// The prefix set is what makes searching a board practical. Without it a
/// walk has to try every path and there are millions; with it a walk stops the
/// moment the letters so far cannot begin anything, which prunes almost all of
/// them. It costs memory once at startup and saves work on every board.
class Lexicon {
  Lexicon._(this._words, this._prefixes);

  /// Build from the shipped list. Takes a moment, so build one and keep it.
  factory Lexicon.standard() => Lexicon.of(kWords);

  /// Build from a given list, which is what tests use so they do not depend on
  /// the whole dictionary being present or on any particular word being in it.
  factory Lexicon.of(Iterable<String> words) {
    final kept = <String>{};
    final prefixes = <String>{''};
    for (final raw in words) {
      final word = raw.toLowerCase();
      if (word.length < shortest || word.length > longest) continue;
      kept.add(word);
      for (var i = 1; i <= word.length; i++) {
        prefixes.add(word.substring(0, i));
      }
    }
    return Lexicon._(kept, prefixes);
  }

  /// The fewest letters a trace can spell and still count.
  static const shortest = 4;

  /// The most. A longer trace is more thumb than anybody wants.
  static const longest = 9;

  final Set<String> _words;
  final Set<String> _prefixes;

  bool knows(String word) => _words.contains(word.toLowerCase());

  /// Whether anything at all starts with these letters.
  bool couldStart(String letters) => _prefixes.contains(letters.toLowerCase());

  int get size => _words.length;

  /// Every word, for a caller that needs to pick one. The order is the set's
  /// own and is not meaningful.
  Iterable<String> get words => _words;
}
