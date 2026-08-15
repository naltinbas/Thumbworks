import 'level.dart';
import 'rules.dart';

/// A load being balanced. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.placing, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, List.filled(Rules.weights.length, Side.off), 0, null);

  /// A play stood at a placing, for the mark and the tests.
  factory Play.standing(Level level, List<Side> placing) =>
      Play._(level, List.of(placing), placing.where((s) => s != Side.off).length, null);

  final Level level;

  /// Where each weight stands, 1, 3, 9 and 27 in that order.
  final List<Side> placing;

  /// Weights moved, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless load admits it.
  static const gaveUpAt = 12;

  int get net => Rules.net(placing);

  int get across => [for (var i = 0; i < 4; i++) if (placing[i] == Side.against) Rules.weights[i]].fold(0, (a, b) => a + b);

  int get beside => [for (var i = 0; i < 4; i++) if (placing[i] == Side.withLoad) Rules.weights[i]].fold(0, (a, b) => a + b);

  /// Which way the beam tips: nought level, more than nought when the
  /// load's pan is the heavier, less when the weights across are.
  int get tilt => level.load + beside - across;

  bool get isDone => tilt == 0;

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  bool barred(int i) => level.barred.contains(Rules.weights[i]);

  bool touches(int i) => !isOver && i >= 0 && i < 4 && !barred(i);

  /// Taps a weight: off to across, across to beside the load, beside to
  /// off.
  Play tap(int i) {
    if (!touches(i)) return this;
    final next = Side.values[(placing[i].index + 1) % 3];
    return Play._(level, [for (var k = 0; k < 4; k++) k == i ? next : placing[k]], moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('move', weight) for the first weight
  /// off the placing counting in threes gives; null when nothing lands.
  (String, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = Rules.balancedTernary(level.load);
    if (aim == null) return null;
    for (var i = 0; i < 4; i++) {
      if (placing[i] != aim[i]) return ('move', i);
    }
    return null;
  }
}
