import 'level.dart';
import 'rules.dart';

/// A string being derived. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.string, this.steps, this.before);

  factory Play.of(Level level) => Play._(level, Rules.start, 0, null);

  /// A play stood at a string, for the mark and the tests.
  factory Play.standing(Level level, String string, int steps) => Play._(level, string, steps, null);

  final Level level;
  final String string;

  /// Steps taken.
  final int steps;

  final Play? before;

  /// The line past which the hopeless string admits it.
  static const gaveUpAt = 12;

  int get iCount => Rules.iCount(string);

  List<(int, int)> get moves => Rules.moves(string);

  bool get isDone => string == level.target && steps <= level.steps;

  bool get spent => steps >= level.steps;

  /// No rule applies to the string on the sheet: a dead end.
  bool get stuck => moves.isEmpty;

  /// The steps spent, or a dead end, on a string that could have been
  /// derived.
  bool get missed => level.winnable && (spent || stuck) && string != level.target;

  bool get gaveUp => !level.winnable && (steps >= gaveUpAt || stuck);

  bool get isOver => isDone || missed || gaveUp;

  /// Makes [move], if it applies.
  Play make((int, int) move) {
    if (isOver) return this;
    final next = Rules.apply(string, move);
    if (next == null) return this;
    return Play._(level, next, steps + 1, this);
  }

  /// Taps letter [p]: rule three where III starts, rule four where UU
  /// starts, else nothing.
  Play tap(int p) {
    if (moves.contains((3, p))) return make((3, p));
    if (moves.contains((4, p))) return make((4, p));
    return this;
  }

  Play get back => before ?? this;

  /// What the show-me points at: the first move of a shortest derivation
  /// from here to the target; null when nothing lands.
  (int, int)? get next {
    if (isOver || !level.winnable) return null;
    final path = pathFrom(string, level.target);
    if (path == null || path.isEmpty) return null;
    return path.first;
  }

  /// A shortest derivation from [from] to [target] on the sheet, or null.
  static List<(int, int)>? pathFrom(String from, String target) {
    if (from == target) return const [];
    final seen = <String, (String, (int, int))?>{from: null};
    final queue = [from];
    var head = 0;
    while (head < queue.length) {
      final s = queue[head++];
      for (final m in Rules.moves(s)) {
        final t = Rules.apply(s, m)!;
        if (seen.containsKey(t)) continue;
        seen[t] = (s, m);
        if (t == target) {
          final out = <(int, int)>[];
          var x = t;
          while (x != from) {
            final (p, mv) = seen[x]!;
            out.add(mv);
            x = p;
          }
          return out.reversed.toList();
        }
        queue.add(t);
      }
    }
    return null;
  }
}
