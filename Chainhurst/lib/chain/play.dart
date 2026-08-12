import 'field.dart';
import 'rules.dart';

/// A field being set. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.field, this.stones, this.moves, this.before);

  factory Play.of(Field field) => Play._(field, const [], 0, null);

  /// A play stood at a placing, for the mark and the tests.
  factory Play.standing(Field field, List<(int, int)> stones) =>
      Play._(field, List.of(stones), stones.length, null);

  final Field field;

  /// The stones as they stand, in the order set.
  final List<(int, int)> stones;

  /// Stones set and lifted, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless field admits it.
  static const gaveUpAt = 16;

  List<List<(int, int)>> get chainsNow => Rules.chains(stones);

  int get bare => Rules.bareByChains(stones);

  int get laden =>
      chainsNow.where((chain) => chain.length > 2).length;

  bool get allSet => stones.length == field.stones;

  bool get rowBarred =>
      field.offRow && allSet && Rules.allInOneRow(stones);

  bool get isDone =>
      allSet && !rowBarred && bare == field.asked;

  bool get gaveUp =>
      !field.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Sets a stone on an empty crossing, or lifts the one there.
  Play tapAt((int, int) spot) {
    if (isOver) return this;
    if (stones.contains(spot)) {
      return Play._(field,
          [for (final s in stones) if (s != spot) s], moves + 1, this);
    }
    if (allSet) return this;
    return Play._(field, [...stones, spot], moves + 1, this);
  }

  Play get back => before ?? this;

  /// A placing that lands the asking, found by the sweep; null on
  /// the hopeless field.
  List<(int, int)>? get exemplar {
    List<(int, int)>? found;
    Rules.placings(field.stones, (placed) {
      if (found != null) return;
      if (field.offRow && Rules.allInOneRow(placed)) return;
      if (Rules.bareByChains(placed) == field.asked) {
        found = List.of(placed);
      }
    });
    return found;
  }

  /// The next touch towards the exemplar: lift a stray stone
  /// first, then set a missing one. Null when nothing is wanted.
  (int, int)? get next {
    final aim = exemplar;
    if (aim == null || isDone) return null;
    for (final stone in stones) {
      if (!aim.contains(stone)) return stone;
    }
    for (final spot in aim) {
      if (!stones.contains(spot)) return spot;
    }
    return null;
  }
}
