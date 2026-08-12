import 'ring.dart';
import 'rules.dart';

/// A ring being tried. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.ring, this.tried, this.found, this.walking, this.before);

  factory Play.of(Ring ring) =>
      Play._(ring, const {}, const [], null, null);

  final Ring ring;

  /// Every start tried so far.
  final Set<int> tried;

  /// The good starts found, in the order they were found.
  final List<int> found;

  /// The start whose walk is on show, or null.
  final int? walking;

  final Play? before;

  bool get isDone => found.length >= ring.goods && ring.winnable;

  /// The hopeless ring admits it once every start has been tried.
  bool get gaveUp =>
      !ring.winnable && tried.length >= ring.marks.length;

  bool get isOver => isDone || gaveUp;

  /// Try a start: the walk shows, and a good one is kept.
  Play tryStart(int start) {
    if (isOver) return this;
    final good = Rules.staysAhead(ring.marks, start);
    return Play._(
      ring,
      {...tried, start},
      good && !found.contains(start) ? [...found, start] : found,
      start,
      this,
    );
  }

  Play get back => before ?? this;

  /// The walk on show, tally by tally; empty when none is.
  List<int> get shownWalk {
    final start = walking;
    if (start == null) return const [];
    return Rules.walkFrom(ring.marks, start);
  }

  /// Whether the walk on show stayed ahead.
  bool get shownGood {
    final start = walking;
    return start != null && Rules.staysAhead(ring.marks, start);
  }

  /// A good start not yet found, for the pointer: the one past the
  /// ebb first, then the walk's own list. Null when none remain.
  int? get next {
    if (!ring.winnable) return null;
    final ebb = Rules.pastTheEbb(ring.marks);
    if (!found.contains(ebb)) return ebb;
    for (final start in Rules.goodStarts(ring.marks)) {
      if (!found.contains(start)) return start;
    }
    return null;
  }
}
