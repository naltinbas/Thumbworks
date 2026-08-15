import 'reach.dart';
import 'rules.dart';

/// A reach being leapt for. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.reach, this.rules, this.frogs, this.picked, this.moves,
      this.before);

  factory Play.of(Reach reach) => Play._(
      reach, Rules(reach.reach, reach.army), reach.army.toSet(), null, 0, null);

  /// A play stood at a standing, for the mark and the tests.
  factory Play.standing(Reach reach, Set<Pad> frogs, {int moves = 1}) =>
      Play._(reach, Rules(reach.reach, reach.army), frogs, null, moves, null);

  final Reach reach;
  final Rules rules;

  /// The frogs as they stand.
  final Set<Pad> frogs;

  /// The frog picked to leap, or null.
  final Pad? picked;

  /// Leaps taken, counted every one.
  final int moves;

  final Play? before;

  /// The line past which the hopeless reach admits it.
  static const gaveUpAt = 12;

  bool get isDone => rules.reached(frogs);

  bool get gaveUp => !reach.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// The army's weight against the aim, as a number.
  double get weight => rules.weightOf(frogs);

  /// The leaps open now.
  List<Leap> get open => rules.leaps(frogs);

  /// The leaps open to the picked frog.
  List<Leap> get openToPicked =>
      [for (final leap in open) if (leap.from == picked) leap];

  /// Taps a pad: picks a frog, unpicks it, or, with a frog
  /// picked and an empty pad two away tapped over a neighbour,
  /// leaps.
  Play tap(Pad pad) {
    if (isOver) return this;
    if (frogs.contains(pad)) {
      return Play._(reach, rules, frogs, picked == pad ? null : pad, moves,
          before);
    }
    final from = picked;
    if (from == null) return this;
    for (final leap in openToPicked) {
      if (leap.to == pad) {
        return Play._(reach, rules, rules.after(frogs, leap), null,
            moves + 1, this);
      }
    }
    return this;
  }

  Play get back => before ?? this;

  /// What the show-me points at: a leap on some road to the aim,
  /// or null when no road lands from here.
  Leap? get next => isOver || !reach.winnable ? null : rules.next(frogs);

  /// Whether any road lands from here.
  bool get lands => rules.lands(frogs);
}
