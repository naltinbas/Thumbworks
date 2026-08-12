import 'pantry.dart';
import 'rules.dart';

/// A pantry being racked. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.pantry, this.rules, this.racking, this.moves, this.before);

  factory Play.of(Pantry pantry) => Play._(
      pantry,
      Rules(pantry.top),
      List.filled(pantry.top, 0),
      0,
      null);

  /// A play stood at a racking, for the mark and the tests.
  factory Play.standing(Pantry pantry, List<int> racking) => Play._(
      pantry,
      Rules(pantry.top),
      List.of(racking),
      racking.where((rack) => rack != 0).length,
      null);

  final Pantry pantry;
  final Rules rules;

  /// One rack per jar, nought for the tray.
  final List<int> racking;

  /// Liftings taken, counted gross.
  final int moves;

  final Play? before;

  /// The line past which the hopeless pantry admits it.
  static const gaveUpAt = 24;

  List<(int, int)> get quarrels => rules.quarrels(racking);

  /// How many jars stand racked.
  int get racked => racking.where((rack) => rack != 0).length;

  bool get isDone => rules.lands(racking);

  bool get gaveUp => !pantry.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Lifts one jar to the next rack, the last rack back to the
  /// tray.
  Play liftAt(int jar) {
    if (isOver || jar < 0 || jar >= racking.length) return this;
    final lifted = List.of(racking);
    lifted[jar] = (lifted[jar] + 1) % (pantry.racks + 1);
    return Play._(pantry, rules, lifted, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The jar the show-me points at: the first lift of a
  /// fewest-lifts road to the height racking, or null when none
  /// lands.
  int? get next {
    if (isOver || !pantry.winnable) return null;
    final aim = rules.byHeights();
    for (var jar = 0; jar < racking.length; jar++) {
      if (racking[jar] != aim[jar]) return jar;
    }
    return null;
  }
}
