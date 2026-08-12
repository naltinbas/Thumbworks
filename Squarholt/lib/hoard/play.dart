import 'hoard.dart';
import 'rules.dart';

/// Two tiles being dialled. Every state is a fresh value, and
/// the one before hangs on for take-back.
class Play {
  Play._(this.hoard, this.a, this.b, this.moves, this.before);

  factory Play.of(Hoard hoard) => Play._(hoard, 1, 1, 0, null);

  /// A play stood at two tiles, for the mark and the tests.
  factory Play.standing(Hoard hoard, int a, int b) =>
      Play._(hoard, a, b, 1, null);

  final Hoard hoard;

  /// The two tile widths, dialled apart.
  final int a;
  final int b;

  /// Dial turns taken, counted gross.
  final int moves;

  final Play? before;

  /// The line past which the hopeless hoard admits it.
  static const gaveUpAt = 16;

  int get paid => a * a + b * b;

  bool get isDone => paid == hoard.target;

  bool get gaveUp => !hoard.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Turns the first tile by [by], clamped to the dial.
  Play turnA(int by) {
    final to = (a + by).clamp(1, Rules.widest);
    if (isOver || to == a) return this;
    return Play._(hoard, to, b, moves + 1, this);
  }

  /// Turns the second tile by [by], clamped to the dial.
  Play turnB(int by) {
    final to = (b + by).clamp(1, Rules.widest);
    if (isOver || to == b) return this;
    return Play._(hoard, a, to, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The turn the show-me points at: (first tile?, upward?) on
  /// a nearest writing, or null when none lands.
  (bool, bool)? get next {
    if (isOver) return null;
    (bool, bool)? turn;
    var nearest = 1 << 30;
    for (final (wa, wb) in Rules.writings(hoard.target)) {
      for (final (toA, toB) in [(wa, wb), (wb, wa)]) {
        final steps = (a - toA).abs() + (b - toB).abs();
        if (steps >= nearest) continue;
        nearest = steps;
        turn = a != toA
            ? (true, toA > a)
            : (false, toB > b);
      }
    }
    return turn;
  }
}
