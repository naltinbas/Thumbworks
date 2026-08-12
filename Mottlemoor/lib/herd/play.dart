import 'moor.dart';
import 'rules.dart';

/// A moor being herded. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.moor, this.rules, this.herds, this.meetingsMade,
      this.before);

  Play.of(Moor moor)
      : this._(moor, _rulesFor(moor), moor.herds, 0, null);

  final Moor moor;
  final Rules rules;

  /// The herds as they stand.
  final (int, int, int) herds;

  /// Meetings made so far.
  final int meetingsMade;

  final Play? before;

  static final _kept = <int, Rules>{};

  static Rules _rulesFor(Moor moor) =>
      _kept[moor.total] ??= Rules(moor.total);

  bool get isSettled => rules.isSettled(herds);

  int countOf(int herd) =>
      [herds.$1, herds.$2, herds.$3][herd];

  bool mayMeet(int one, int other) =>
      !isSettled &&
      one != other &&
      one >= 0 &&
      other >= 0 &&
      one < 3 &&
      other < 3 &&
      countOf(one) > 0 &&
      countOf(other) > 0;

  /// One meeting. The moor comes back unchanged if it may not be
  /// made.
  Play meet(int one, int other) {
    if (!mayMeet(one, other)) return this;
    final low = one < other ? one : other;
    final high = one < other ? other : one;
    return Play._(moor, rules, rules.met(herds, low, high),
        meetingsMade + 1, this);
  }

  Play get back => before ?? this;

  /// The fewest meetings from here, or null.
  int? get fewestFromHere => rules.fewest(herds);

  /// A meeting that steps one nearer, or null.
  (int, int)? get next => rules.next(herds);
}
