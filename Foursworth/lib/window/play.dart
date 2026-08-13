import 'house.dart';
import 'rules.dart';

/// A house being dialled. Every state is a fresh value, and
/// the one before hangs on for take-back.
class Play {
  Play._(this.house, this.windows, this.moves, this.before);

  factory Play.of(House house) =>
      Play._(house, List.filled(house.count, 0), 0, null);

  /// A play stood at a dialling, for the mark and the tests.
  factory Play.standing(House house, List<int> windows) =>
      Play._(house, List.of(windows), 1, null);

  final House house;

  /// The faces as dialled.
  final List<int> windows;

  /// Taps taken, counted gross.
  final int moves;

  final Play? before;

  /// The line past which the hopeless house admits it.
  static const gaveUpAt = 14;

  List<List<int>> get road => Rules.walk(windows);

  int get turns => Rules.turnsToDark(windows);

  bool get isDone => moves > 0 && turns == house.asked;

  bool get gaveUp => !house.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Taps one window: its face turns one up and wraps past
  /// seven.
  Play tapAt(int window) {
    if (isOver || window < 0 || window >= windows.length) {
      return this;
    }
    final dialled = List.of(windows);
    dialled[window] = (dialled[window] + 1) % (Rules.brightest + 1);
    return Play._(house, dialled, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The window the show-me points at: the first tap of a
  /// fewest-taps road to a landing, or null when none lands.
  int? get next {
    if (isOver || !house.winnable) return null;
    List<int>? bestAim;
    var fewest = 1 << 30;
    Rules.diallings(house.count, (aim) {
      if (Rules.turnsToDark(aim) != house.asked) return;
      var taps = 0;
      for (var at = 0; at < windows.length; at++) {
        taps += (aim[at] - windows[at]) % (Rules.brightest + 1);
      }
      if (taps < fewest && taps > 0) {
        fewest = taps;
        bestAim = List.of(aim);
      }
    });
    final aim = bestAim;
    if (aim == null) return null;
    for (var at = 0; at < windows.length; at++) {
      if (aim[at] != windows[at]) return at;
    }
    return null;
  }
}
