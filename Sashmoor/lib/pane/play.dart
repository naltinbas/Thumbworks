import 'rules.dart';
import 'sash.dart';

/// A sash being glazed. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.sash, this.rules, this.panes, this.moves, this.before);

  factory Play.of(Sash sash) => Play._(
      sash, Rules(sash.across, sash.down), const [], 0, null);

  /// A play stood at a placing, for the mark and the tests.
  factory Play.standing(Sash sash, List<(int, int)> panes) => Play._(
      sash,
      Rules(sash.across, sash.down),
      List.of(panes),
      panes.length,
      null);

  final Sash sash;
  final Rules rules;

  /// The panes as they stand, in the order set.
  final List<(int, int)> panes;

  /// Panes set and lifted, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless sash admits it.
  static const gaveUpAt = 16;

  List<((int, int), (int, int), (int, int), (int, int))>
      get framed => rules.windows(panes);

  int get windows => framed.length;

  bool get allSet => panes.length == sash.count;

  bool get isDone => allSet && windows == 0;

  bool get gaveUp => !sash.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Sets a pane in an empty light, or lifts the one there.
  Play tapAt((int, int) light) {
    if (isOver) return this;
    if (panes.contains(light)) {
      return Play._(sash, rules,
          [for (final p in panes) if (p != light) p], moves + 1, this);
    }
    if (allSet) return this;
    return Play._(sash, rules, [...panes, light], moves + 1, this);
  }

  Play get back => before ?? this;

  /// A placing that lands the asking, found by the sweep; null on
  /// the hopeless sash.
  List<(int, int)>? get exemplar {
    List<(int, int)>? found;
    rules.placings(sash.count, (placed) {
      if (found != null) return;
      if (rules.windowFree(placed)) found = List.of(placed);
    });
    return found;
  }

  /// The next touch towards the exemplar: lift a stray pane
  /// first, then set a missing one. Null when nothing is wanted.
  (int, int)? get next {
    final aim = exemplar;
    if (aim == null || isDone) return null;
    for (final pane in panes) {
      if (!aim.contains(pane)) return pane;
    }
    for (final light in aim) {
      if (!panes.contains(light)) return light;
    }
    return null;
  }
}
