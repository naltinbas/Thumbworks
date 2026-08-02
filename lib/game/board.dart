
import 'lexicon.dart';

/// A square on the board.
class Spot {
  const Spot(this.row, this.col);

  final int row;
  final int col;

  /// Whether a trace may go straight from here to [other].
  ///
  /// Neighbouring includes the diagonals, which is what lets a board of this
  /// size hold interesting words: without them a five by five grid has very
  /// little in it.
  bool touches(Spot other) {
    final dr = (row - other.row).abs();
    final dc = (col - other.col).abs();
    return (dr | dc) != 0 && dr <= 1 && dc <= 1;
  }

  @override
  bool operator ==(Object other) =>
      other is Spot && other.row == row && other.col == col;

  @override
  int get hashCode => row * 31 + col;

  @override
  String toString() => '($row,$col)';
}

/// Why a trace was not accepted, so the game can say something useful rather
/// than just refusing.
enum Refusal {
  /// The trace is fine, and the word counts.
  none,

  /// Fewer letters than the shortest word the game accepts.
  tooShort,

  /// Two squares in the trace are not next to each other.
  broken,

  /// The same square used twice.
  repeated,

  /// Spelled correctly, traced correctly, and already found.
  alreadyFound,

  /// Not a word this game knows.
  unknown,
}

/// A board of letters, and the words found on it so far.
///
/// Immutable: finding a word gives a new board. That keeps the animation
/// honest and lets a test hold a position and compare it with what a trace
/// produced.
class Board {
  Board({
    required this.size,
    required List<String> letters,
    required this.lexicon,
    Set<String>? found,
  })  : assert(letters.length == size * size, 'letters must fill the board'),
        _letters = List.unmodifiable(letters),
        found = Set.unmodifiable(found ?? const <String>{});

  final int size;
  final List<String> _letters;
  final Lexicon lexicon;

  /// The words the player has traced, lower case.
  final Set<String> found;

  String letterAt(Spot spot) => _letters[spot.row * size + spot.col];

  bool inside(Spot spot) =>
      spot.row >= 0 && spot.row < size && spot.col >= 0 && spot.col < size;

  /// The word a trace spells, whether or not it is a real one.
  String wordFor(List<Spot> trace) =>
      trace.map(letterAt).join().toLowerCase();

  /// What the game would say about this trace.
  Refusal judge(List<Spot> trace) {
    if (trace.length < Lexicon.shortest) return Refusal.tooShort;

    final seen = <Spot>{};
    for (var i = 0; i < trace.length; i++) {
      if (!seen.add(trace[i])) return Refusal.repeated;
      if (i > 0 && !trace[i - 1].touches(trace[i])) return Refusal.broken;
    }

    final word = wordFor(trace);
    if (found.contains(word)) return Refusal.alreadyFound;
    if (!lexicon.knows(word)) return Refusal.unknown;
    return Refusal.none;
  }

  /// The board with this trace's word added, or this board if it was refused.
  Board take(List<Spot> trace) {
    if (judge(trace) != Refusal.none) return this;
    return Board(
      size: size,
      letters: _letters,
      lexicon: lexicon,
      found: {...found, wordFor(trace)},
    );
  }

  /// What a word is worth: longer words are worth disproportionately more,
  /// because the difficulty of finding one grows much faster than its length.
  static int scoreOf(String word) => switch (word.length) {
        <= 4 => 1,
        5 => 2,
        6 => 4,
        7 => 7,
        8 => 11,
        _ => 16,
      };

  int get score => found.fold(0, (sum, word) => sum + scoreOf(word));

  /// Every word on this board that the lexicon knows.
  ///
  /// Walks from each square, extending only while the letters so far are the
  /// start of something, which is what keeps this fast enough to run when a
  /// board is made rather than only in a test.
  Set<String> get everyWord {
    final words = <String>{};
    final trace = <Spot>[];
    final used = List<bool>.filled(size * size, false);

    void walk(Spot at, String prefix) {
      final word = prefix + letterAt(at);
      if (!lexicon.couldStart(word)) return;

      trace.add(at);
      used[at.row * size + at.col] = true;

      if (word.length >= Lexicon.shortest && lexicon.knows(word)) {
        words.add(word);
      }
      if (word.length < Lexicon.longest) {
        for (var dr = -1; dr <= 1; dr++) {
          for (var dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            final next = Spot(at.row + dr, at.col + dc);
            if (!inside(next)) continue;
            if (used[next.row * size + next.col]) continue;
            walk(next, word);
          }
        }
      }

      trace.removeLast();
      used[at.row * size + at.col] = false;
    }

    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        walk(Spot(row, col), '');
      }
    }
    return words;
  }
}
