import 'frame.dart';
import 'rules.dart';

/// An alley being bowled. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.frame, this.standing, this.knocks, this.before);

  Play.of(Frame frame)
      : this._(
            frame,
            [for (final row in frame.rows) (1 << row) - 1],
            0,
            null);

  final Frame frame;

  /// Which skittles stand, one mask per original row.
  final List<int> standing;

  /// Knocks made so far, the house's included.
  final int knocks;

  final Play? before;

  bool stands(int row, int pin) => standing[row] & (1 << pin) != 0;

  bool get isCleared => standing.every((row) => row == 0);

  /// The maximal runs of standing skittles, across all rows.
  List<int> get segments {
    final out = <int>[];
    for (var row = 0; row < frame.rows.length; row++) {
      var run = 0;
      for (var pin = 0; pin < frame.rows[row]; pin++) {
        if (stands(row, pin)) {
          run++;
        } else if (run > 0) {
          out.add(run);
          run = 0;
        }
      }
      if (run > 0) out.add(run);
    }
    return out;
  }

  /// The alley's count as it stands.
  int get count => Rules.countAlley(segments);

  bool mayKnockOne(int row, int pin) =>
      row >= 0 &&
      row < frame.rows.length &&
      pin >= 0 &&
      pin < frame.rows[row] &&
      stands(row, pin);

  bool mayKnockTwo(int row, int pin, int other) =>
      (other - pin).abs() == 1 &&
      mayKnockOne(row, pin) &&
      mayKnockOne(row, other);

  Play knockOne(int row, int pin) {
    if (!mayKnockOne(row, pin)) return this;
    final next = [...standing];
    next[row] &= ~(1 << pin);
    return Play._(frame, next, knocks + 1, this);
  }

  Play knockTwo(int row, int pin, int other) {
    if (!mayKnockTwo(row, pin, other)) return this;
    final next = [...standing];
    next[row] &= ~(1 << pin);
    next[row] &= ~(1 << other);
    return Play._(frame, next, knocks + 1, this);
  }

  Play get back => before ?? this;

  /// Every legal knock: (row, pin, second pin or -1).
  List<(int, int, int)> get allKnocks => [
        for (var row = 0; row < frame.rows.length; row++) ...[
          for (var pin = 0; pin < frame.rows[row]; pin++)
            if (stands(row, pin)) ...[
              (row, pin, -1),
              if (pin + 1 < frame.rows[row] && stands(row, pin + 1))
                (row, pin, pin + 1),
            ],
        ],
      ];

  /// A knock leaving the count at nought, or null when none does.
  (int, int, int)? get zeroing {
    for (final knock in allKnocks) {
      final (row, pin, other) = knock;
      final after =
          other < 0 ? knockOne(row, pin) : knockTwo(row, pin, other);
      if (after.count == 0) return knock;
    }
    return null;
  }

  /// The house's knock: zero the count when it can, else knock the
  /// first thing standing.
  (int, int, int)? get houseKnock {
    if (isCleared) return null;
    return zeroing ?? allKnocks.first;
  }
}
