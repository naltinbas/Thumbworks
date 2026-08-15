import 'rules.dart';
import 'share.dart';

/// A string being cut. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.share, this.rules, this.cuts, this.moves, this.before);

  factory Play.of(Share share) =>
      Play._(share, Rules(share.sweets), const [], 0, null);

  /// A play stood at a set of cuts, for the mark and the tests.
  factory Play.standing(Share share, List<int> cuts) =>
      Play._(share, Rules(share.sweets), List.of(cuts)..sort(), cuts.length, null);

  final Share share;
  final Rules rules;

  /// The cuts as they stand, gap indices sorted.
  final List<int> cuts;

  /// Cuts made and mended, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless share admits it.
  static const gaveUpAt = 9;

  bool get isDone => cuts.length <= share.cuts && rules.fair(cuts);

  bool get gaveUp => !share.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  List<String> get pieces => rules.pieces(cuts);

  (Map<String, int>, Map<String, int>) get shares => rules.shares(cuts);

  /// Whether a gap may be cut: not past the count allowed.
  bool touches(int gap) =>
      !isOver && gap >= 1 && gap < rules.length &&
      (cuts.contains(gap) || cuts.length < share.cuts);

  /// Taps a gap: cuts it, or mends the cut there.
  Play tap(int gap) {
    if (!touches(gap)) return this;
    final held = cuts.contains(gap)
        ? [for (final c in cuts) if (c != gap) c]
        : ([...cuts, gap]..sort());
    return Play._(share, rules, held, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('mend', gap) for a cut off the
  /// aim, or ('cut', gap) for the next cut of the aim; null when
  /// nothing lands.
  (String, int)? get next {
    if (isOver || !share.winnable) return null;
    final aim = rules.landing(share.cuts);
    if (aim == null) return null;
    for (final cut in cuts) {
      if (!aim.contains(cut)) return ('mend', cut);
    }
    for (final cut in aim) {
      if (!cuts.contains(cut)) return ('cut', cut);
    }
    return null;
  }
}
