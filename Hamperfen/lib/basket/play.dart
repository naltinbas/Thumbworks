import 'fen.dart';
import 'rules.dart';

/// A shelf being picked. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.fen, this.taken, this.moves, this.before);

  factory Play.of(Fen fen) => Play._(fen, const [], 0, null);

  /// A play stood at a picking, for the mark and the tests.
  factory Play.standing(Fen fen, List<int> taken) =>
      Play._(fen, List.of(taken), taken.length, null);

  final Fen fen;

  /// The baskets taken, in taking order.
  final List<int> taken;

  /// Takings and handings-back, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless fen admits it.
  static const gaveUpAt = 14;

  List<(int, int)> get swallowings => Rules.swallowings(taken);

  bool get isDone =>
      taken.length == fen.take && swallowings.isEmpty;

  bool get gaveUp => !fen.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Takes a basket from the shelf, or hands it back.
  Play tapAt(int basket) {
    if (isOver || basket < 0 || basket > 15) return this;
    if (taken.contains(basket)) {
      return Play._(fen,
          [for (final held in taken) if (held != basket) held],
          moves + 1, this);
    }
    if (taken.length == fen.take) return this;
    return Play._(fen, [...taken, basket], moves + 1, this);
  }

  Play get back => before ?? this;

  /// The basket the sweep would move next towards a free family;
  /// null when none lands the asking.
  (int, bool)? get next {
    final aim = Rules.family(fen.take);
    if (aim == null || isDone) return null;
    for (final basket in taken) {
      if (!aim.contains(basket)) return (basket, false);
    }
    for (final basket in aim) {
      if (!taken.contains(basket)) return (basket, true);
    }
    return null;
  }
}
