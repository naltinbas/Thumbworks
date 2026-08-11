import 'charm.dart';
import 'rules.dart';

/// A charm being set. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.charm, this.laid, this.moves, this.before);

  Play.of(Charm charm)
      : this._(
            charm,
            [
              for (var cell = 0; cell < 9; cell++) charm.pins[cell],
            ],
            0,
            null);

  final Charm charm;

  /// What lies on each cell, or null.
  final List<int?> laid;

  /// Placings and liftings made so far.
  final int moves;

  final Play? before;

  static final _answers = <String, List<List<int>>>{};

  /// The charms honouring the pins, swept once and kept.
  List<List<int>> get answers =>
      _answers[charm.name] ??= Rules.charmsUnder(charm.pins);

  /// The coins not yet on the bed, in worth order.
  List<int> get tray => [
        for (var coin = 1; coin <= 9; coin++)
          if (!laid.contains(coin)) coin,
      ];

  bool get isFull => !laid.contains(null);

  bool get isDone =>
      isFull && Rules.holds([for (final coin in laid) coin!]);

  /// A line's count so far, and whether it is finished.
  (int, bool) lineCount(int line) {
    var count = 0;
    var full = true;
    for (final cell in Rules.lines[line]) {
      final coin = laid[cell];
      if (coin == null) {
        full = false;
      } else {
        count += coin;
      }
    }
    return (count, full);
  }

  /// The finished lines not counting fifteen.
  List<int> get broken => [
        for (var line = 0; line < Rules.lines.length; line++)
          if (lineCount(line) case (final count, true)
              when count != 15)
            line,
      ];

  bool mayLay(int cell, int coin) =>
      cell >= 0 &&
      cell < 9 &&
      laid[cell] == null &&
      tray.contains(coin);

  /// Lays a coin on a bare cell.
  Play lay(int cell, int coin) {
    if (isDone || !mayLay(cell, coin)) return this;
    final next = [...laid];
    next[cell] = coin;
    return Play._(charm, next, moves + 1, this);
  }

  /// Lifts an unpinned coin back to the tray.
  Play lift(int cell) {
    if (isDone ||
        cell < 0 ||
        cell >= 9 ||
        laid[cell] == null ||
        charm.isPinned(cell)) {
      return this;
    }
    final next = [...laid];
    next[cell] = null;
    return Play._(charm, next, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The laying to mend next, against the nearest charm: a cell and
  /// the coin it wants, or the cell to clear as (cell, null). Null
  /// when done or nothing holds.
  (int, int?)? get next {
    if (isDone || answers.isEmpty) return null;
    List<int>? nearest;
    var most = -1;
    for (final answer in answers) {
      var matches = 0;
      for (var cell = 0; cell < 9; cell++) {
        if (laid[cell] == answer[cell]) matches++;
      }
      if (matches > most) {
        most = matches;
        nearest = answer;
      }
    }
    // Clear a wrong coin first; then fill the first bare cell.
    for (var cell = 0; cell < 9; cell++) {
      if (laid[cell] != null && laid[cell] != nearest![cell]) {
        return (cell, null);
      }
    }
    for (var cell = 0; cell < 9; cell++) {
      if (laid[cell] == null) return (cell, nearest![cell]);
    }
    return null;
  }
}
