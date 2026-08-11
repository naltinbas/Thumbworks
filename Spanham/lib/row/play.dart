import 'fewest.dart';
import 'level.dart';

/// A shelf part set: which blocks sit where, and which pair is in hand.
class Play {
  const Play._(this.level, this.row, this.placing, this.before);

  Play.of(Level level)
      : this._(level, List<int>.filled(level.seats, 0), level.pairs, null);

  final Level level;

  /// The seats, nought for empty, else the pair's number.
  final List<int> row;

  /// The pair in hand, biggest first, or nought when the shelf is set.
  final int placing;

  /// The shelf before the last pair went down, or null at the start.
  final Play? before;

  bool get isSet => placing == 0;

  /// Whether the pair in hand can sit with its left block at [seat].
  bool mayPlace(int seat) {
    if (isSet || seat < 0 || seat + placing + 1 >= level.seats) return false;
    return row[seat] == 0 && row[seat + placing + 1] == 0;
  }

  /// Sets the pair in hand down. Returns this unchanged when it cannot.
  Play place(int seat) {
    if (!mayPlace(seat)) return this;
    final grown = [...row];
    grown[seat] = placing;
    grown[seat + placing + 1] = placing;
    return Play._(level, grown, placing - 1, this);
  }

  /// The last pair back into hand, or this at the start.
  Play get back => before ?? this;

  /// Whether the shelf can still be finished from here.
  bool get canStill => Rows.canStillSet([...row], placing);

  /// A seat for the pair in hand that keeps the shelf finishable, lowest
  /// first, or null when there is none.
  int? get next {
    if (isSet) return null;
    for (var seat = 0; seat + placing + 1 < level.seats; seat++) {
      if (!mayPlace(seat)) continue;
      final tried = place(seat);
      if (Rows.canStillSet([...tried.row], tried.placing)) return seat;
    }
    return null;
  }
}
