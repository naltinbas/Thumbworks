import 'grind.dart';
import 'rules.dart';

/// A mill being wound. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.grind, this.wound, this.moves, this.before);

  factory Play.of(Grind grind) => Play._(grind, 1, 0, null);

  /// A play stood at a winding, for the mark and the tests.
  factory Play.standing(Grind grind, int wound) =>
      Play._(grind, wound, 0, null);

  final Grind grind;

  /// Where the mill stands wound.
  final int wound;

  /// Windings taken, up and down together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless grind admits it.
  static const gaveUpAt = 24;

  List<int> get ledger => Rules.ledger(wound);

  int get noughts => Rules.noughts(wound);

  bool get isDone => moves > 0 && noughts == grind.asked;

  bool get gaveUp => !grind.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Winds the mill by [by], clamped to its range.
  Play windBy(int by) {
    if (isOver) return this;
    final turned = (wound + by).clamp(0, Rules.most);
    if (turned == wound) return this;
    return Play._(grind, turned, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The nearest winding that lands the asking; null when none
  /// does.
  int? get next {
    final landings = Rules.windings(grind.asked);
    if (landings.isEmpty || isDone) return null;
    var nearest = landings.first;
    for (final landing in landings) {
      if ((landing - wound).abs() < (nearest - wound).abs()) {
        nearest = landing;
      }
    }
    return nearest;
  }
}
