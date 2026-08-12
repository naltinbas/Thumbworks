import 'load.dart';
import 'rules.dart';

/// A load being dialled. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.load, this.digits, this.moves, this.before);

  factory Play.of(Load load) => Play._(
      load,
      [
        load.opens ~/ 1000,
        load.opens ~/ 100 % 10,
        load.opens ~/ 10 % 10,
        load.opens % 10,
      ],
      0,
      null);

  /// A play stood at a number, for the mark and the tests.
  factory Play.standing(Load load, int number) => Play._(
      load,
      [
        number ~/ 1000,
        number ~/ 100 % 10,
        number ~/ 10 % 10,
        number % 10,
      ],
      1,
      null);

  final Load load;

  /// The four digits as dialled.
  final List<int> digits;

  /// Taps taken, counted gross.
  final int moves;

  final Play? before;

  /// The line past which the hopeless load admits it.
  static const gaveUpAt = 16;

  int get number =>
      digits[0] * 1000 + digits[1] * 100 + digits[2] * 10 + digits[3];

  bool get barred => Rules.repdigit(number);

  List<int> get road => barred ? [number] : Rules.road(number);

  int get steps => barred ? -1 : Rules.stepsByWalk(number);

  bool get isDone => !barred && steps == load.asked;

  bool get gaveUp => !load.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Taps one dial: its digit steps up and wraps past nine.
  Play tapAt(int slot) {
    if (isOver || slot < 0 || slot >= 4) return this;
    final dialled = List.of(digits);
    dialled[slot] = (dialled[slot] + 1) % 10;
    return Play._(load, dialled, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The dial the show-me points at: the first tap of a
  /// fewest-taps road to a landing, or null when none lands.
  int? get next {
    if (isOver || !load.winnable) return null;
    List<int>? bestAim;
    var fewest = 1 << 30;
    Rules.numbers((n) {
      if (Rules.stepsByWalk(n) != load.asked) return;
      final aim = [
        n ~/ 1000,
        n ~/ 100 % 10,
        n ~/ 10 % 10,
        n % 10,
      ];
      var taps = 0;
      for (var slot = 0; slot < 4; slot++) {
        taps += (aim[slot] - digits[slot]) % 10;
      }
      if (taps < fewest) {
        fewest = taps;
        bestAim = aim;
      }
    });
    final aim = bestAim;
    if (aim == null) return null;
    for (var slot = 0; slot < 4; slot++) {
      if (aim[slot] != digits[slot]) return slot;
    }
    return null;
  }
}
