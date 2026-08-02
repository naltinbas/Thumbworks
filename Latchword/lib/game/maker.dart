import 'dart:math';

import 'board.dart';
import 'lexicon.dart';

/// Makes boards worth playing.
///
/// A grid of random letters is usually a bad board: it has almost nothing in
/// it, and a player who stares at it and finds nothing blames themselves. So a
/// board is made by seeding it with a real word and filling the rest from the
/// frequencies English actually has, and then it is checked. A board that does
/// not hold enough words is thrown away rather than handed over.
///
/// That check is the whole point. The generator does not hope a board is
/// playable, it counts.
class Maker {
  Maker({required this.lexicon, Random? random})
      : _random = random ?? Random();

  final Lexicon lexicon;
  final Random _random;

  /// How many words a board must hold before it is worth playing.
  static const enough = 25;

  /// Letters in roughly the proportion English uses them, so a board reads as
  /// language rather than as noise. A grid of uniformly random letters is
  /// mostly consonants nobody can use.
  static const _bag =
      'aaaaaaaaabbccddddeeeeeeeeeeeeffgghhhhhiiiiiiiiijkkllllmmnnnnnn'
      'ooooooooppqrrrrrrssssssttttttttuuuuvvwwxyyz';

  /// A board of this size that holds at least [enough] words.
  ///
  /// Tries seeded boards first, since a board built around a real word almost
  /// always holds plenty. If a great many attempts fail, the last one is
  /// returned rather than looping forever, and the caller can ask how many
  /// words it holds.
  Board make({int size = 5, int attempts = 60}) {
    Board? best;
    var bestCount = -1;

    for (var attempt = 0; attempt < attempts; attempt++) {
      final board = _attempt(size);
      final count = board.everyWord.length;
      if (count > bestCount) {
        best = board;
        bestCount = count;
      }
      if (count >= enough) return board;
    }
    return best!;
  }

  /// One try: lay a real word along a wandering path, then fill the rest.
  Board _attempt(int size) {
    final letters = List<String>.filled(size * size, '');

    final seed = _seedWord(size);
    if (seed != null) {
      final path = _wander(size, seed.length);
      if (path != null) {
        for (var i = 0; i < seed.length; i++) {
          letters[path[i].row * size + path[i].col] = seed[i];
        }
      }
    }

    for (var i = 0; i < letters.length; i++) {
      if (letters[i].isEmpty) {
        letters[i] = _bag[_random.nextInt(_bag.length)];
      }
    }

    return Board(size: size, letters: letters, lexicon: lexicon);
  }

  /// A word to build the board around: long enough to be worth finding, short
  /// enough to fit a path that does not have to double back on itself.
  String? _seedWord(int size) {
    final wanted = min(Lexicon.longest, size + 2);
    for (var tries = 0; tries < 200; tries++) {
      final word = _randomWord();
      if (word.length >= 5 && word.length <= wanted) return word;
    }
    return null;
  }

  String _randomWord() {
    // The lexicon does not expose its words in order, and building a list of
    // forty thousand every time would be waste, so the words are taken from
    // the set's iteration order at a random offset. It is not uniform, and it
    // does not need to be: it only has to vary.
    final skip = _random.nextInt(lexicon.size);
    var i = 0;
    for (final word in lexicon.words) {
      if (i++ == skip) return word;
    }
    return 'stone';
  }

  /// A path of touching squares, no square twice, for laying a word along.
  List<Spot>? _wander(int size, int length) {
    for (var tries = 0; tries < 40; tries++) {
      final path = <Spot>[Spot(_random.nextInt(size), _random.nextInt(size))];
      final used = <Spot>{path.first};

      while (path.length < length) {
        final options = <Spot>[];
        for (var dr = -1; dr <= 1; dr++) {
          for (var dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            final next = Spot(path.last.row + dr, path.last.col + dc);
            if (next.row < 0 || next.row >= size) continue;
            if (next.col < 0 || next.col >= size) continue;
            if (used.contains(next)) continue;
            options.add(next);
          }
        }
        if (options.isEmpty) break;
        final pick = options[_random.nextInt(options.length)];
        path.add(pick);
        used.add(pick);
      }

      if (path.length == length) return path;
    }
    return null;
  }
}
