import 'fraction.dart';
import 'loaf.dart';
import 'rules.dart';

/// A share being cut. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.loaf, this.rules, this.cuts, this.moves, this.before);

  factory Play.of(Loaf loaf) => Play._(loaf, Rules(loaf.share), const [], 0, null);

  /// A play stood at a set of cuts, for the mark and the tests.
  factory Play.standing(Loaf loaf, List<int> cuts) =>
      Play._(loaf, Rules(loaf.share), List.of(cuts)..sort(), cuts.length, null);

  final Loaf loaf;
  final Rules rules;

  /// The cuts taken, denominators sorted.
  final List<int> cuts;

  /// Cuts taken and put back, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless share admits it.
  static const gaveUpAt = 10;

  Fraction get sum => Rules.sumOf(cuts);

  /// What is still to cut, or nought when over.
  Fraction get left => sum > loaf.share ? Fraction.zero : loaf.share - sum;

  bool get over => sum > loaf.share;

  bool get isDone => cuts.length <= loaf.cuts && sum == loaf.share;

  bool get gaveUp => !loaf.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Whether a cut may be touched: on the board, and room for it.
  bool touches(int den) =>
      !isOver && den >= 2 && den <= rules.largest &&
      (cuts.contains(den) || cuts.length < loaf.cuts);

  /// Taps a cut: takes it, or puts it back.
  Play tap(int den) {
    if (!touches(den)) return this;
    final held = cuts.contains(den)
        ? [for (final c in cuts) if (c != den) c]
        : ([...cuts, den]..sort());
    return Play._(loaf, rules, held, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('back', den) for a cut off the
  /// aim, or ('take', den) for the next cut of the aim; null when
  /// nothing lands.
  (String, int)? get next {
    if (isOver || !loaf.winnable) return null;
    final aim = rules.landing(loaf.cuts);
    if (aim == null) return null;
    for (final cut in cuts) {
      if (!aim.contains(cut)) return ('back', cut);
    }
    for (final cut in aim) {
      if (!cuts.contains(cut)) return ('take', cut);
    }
    return null;
  }
}
