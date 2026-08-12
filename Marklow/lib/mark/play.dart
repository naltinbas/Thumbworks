import 'low.dart';
import 'rules.dart';

/// A low being numbered. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.low, this.rules, this.numbering, this.moves, this.before);

  factory Play.of(Low low) => Play._(
        low,
        Rules(low.posts, low.lines),
        List.filled(low.posts, -1),
        0,
        null,
      );

  /// A play stood at a numbering, for the mark and the tests.
  factory Play.standing(Low low, List<int> numbering) => Play._(
      low, Rules(low.posts, low.lines), List.of(numbering), 0, null);

  final Low low;
  final Rules rules;

  /// Each post's number, -1 while bare.
  final List<int> numbering;

  /// Renumberings taken.
  final int moves;

  final Play? before;

  /// The line past which the hopeless low admits it.
  static const gaveUpAt = 12;

  List<int> get gaps => rules.gaps(numbering);

  List<int> get clashes => rules.clashes(numbering);

  List<int> get repeats => rules.repeats(numbering);

  bool get isDone => rules.graceful(numbering);

  bool get gaveUp => !low.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Cycles a post's mark: bare, nought, one, up to the line
  /// count, and bare again.
  Play tapAt(int post) {
    if (isOver || post < 0 || post >= low.posts) return this;
    final next = List.of(numbering);
    next[post] =
        next[post] >= low.lines.length ? -1 : next[post] + 1;
    return Play._(low, rules, next, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The post the sweep would renumber next towards a graceful
  /// numbering, with the mark it wants; null when none exists.
  (int, int)? get next {
    final aim = rules.numbering();
    if (aim == null || isDone) return null;
    for (var post = 0; post < low.posts; post++) {
      if (numbering[post] != aim[post]) return (post, aim[post]);
    }
    return null;
  }
}
