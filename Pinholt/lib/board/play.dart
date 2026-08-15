import 'plot.dart';
import 'rules.dart';

/// A board being pinned. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.plot, this.rules, this.pins, this.moves, this.before,
      this.refused);

  factory Play.of(Plot plot) => Play._(plot, Rules(5), const [], 0, null, null);

  /// A play stood at a placing, for the mark and the tests.
  factory Play.standing(Plot plot, List<Hole> pins) =>
      Play._(plot, Rules(5), List.of(pins), pins.length, null, null);

  final Plot plot;
  final Rules rules;

  /// The pins as set, in the order set.
  final List<Hole> pins;

  /// Pins set and lifted, counted together.
  final int moves;

  final Play? before;

  /// The hole last refused for lining up, or null.
  final Hole? refused;

  /// The line past which the hopeless plot admits it.
  static const gaveUpAt = 11;

  List<List<Hole>> get frames => Rules.frames(pins);

  List<Hole> get fence => Rules.fence(pins);

  bool get isDone => pins.length == plot.pins && frames.length == plot.asked;

  bool get gaveUp => !plot.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Taps a hole: lifts the pin there, or sets one when there is
  /// room and it does not line up with two others.
  Play tap(Hole hole) {
    if (isOver) return this;
    if (pins.contains(hole)) {
      return Play._(plot, rules,
          [for (final p in pins) if (p != hole) p], moves + 1, this, null);
    }
    if (pins.length >= plot.pins) return this;
    if (Rules.linesUp(pins, hole)) {
      return Play._(plot, rules, pins, moves, before, hole);
    }
    return Play._(plot, rules, [...pins, hole], moves + 1, this, null);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('lift', hole) for a pin off the
  /// aim, or ('set', hole) for the next hole of the aim; null when
  /// nothing lands.
  (String, Hole)? get next {
    if (isOver || !plot.winnable) return null;
    final aim = rules.landing(plot.pins, plot.asked);
    if (aim == null) return null;
    for (final pin in pins) {
      if (!aim.contains(pin)) return ('lift', pin);
    }
    for (final hole in aim) {
      if (!pins.contains(hole)) return ('set', hole);
    }
    return null;
  }
}
