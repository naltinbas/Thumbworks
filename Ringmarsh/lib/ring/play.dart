import 'rules.dart';
import 'watch.dart';

/// A ring being set. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.watch, this.rules, this.ring, this.turns, this.before);

  Play.of(Watch watch)
      : this._(watch, _rulesFor(watch), watch.lockedBits, 0, null);

  final Watch watch;
  final Rules rules;

  /// The lanterns, lit bits.
  final int ring;

  /// Turns made so far.
  final int turns;

  final Play? before;

  static final _kept = <String, Rules>{};
  static final _answers = <String, List<int>>{};

  static Rules _rulesFor(Watch watch) =>
      _kept[watch.name] ??= Rules(watch.span, watch.length);

  /// Every full ring honouring the locks, swept once and kept.
  List<int> get answers => _answers[watch.name] ??=
      rules.fullRingsUnder(watch.lockedPlaces, watch.lockedBits);

  bool get isFull => rules.isFull(ring);

  bool lit(int place) => ring & (1 << place) != 0;

  int get speltCount => rules.speltCount(ring);

  List<(int, int)> get clashes => rules.clashes(ring);

  bool mayTurn(int place) =>
      !isFull &&
      place >= 0 &&
      place < watch.length &&
      !watch.isLocked(place);

  /// Turns a lantern. The ring comes back unchanged if it may not.
  Play turn(int place) {
    if (!mayTurn(place)) return this;
    return Play._(
        watch, rules, ring ^ (1 << place), turns + 1, this);
  }

  Play get back => before ?? this;

  static int _weigh(int mask) {
    var count = 0;
    var bits = mask;
    while (bits != 0) {
      bits &= bits - 1;
      count++;
    }
    return count;
  }

  /// How few lantern-turns reach a full watch from here, or null when
  /// none does.
  int? get fewestFromHere {
    if (answers.isEmpty) return null;
    var least = watch.length + 1;
    for (final answer in answers) {
      final away = _weigh(answer ^ ring);
      if (away < least) least = away;
    }
    return least;
  }

  /// A lantern whose turn steps toward the nearest full watch, or
  /// null.
  int? get next {
    if (isFull || answers.isEmpty) return null;
    var bestAway = watch.length + 1;
    var best = -1;
    for (final answer in answers) {
      final away = _weigh(answer ^ ring);
      if (away < bestAway) {
        bestAway = away;
        best = answer;
      }
    }
    if (best < 0) return null;
    for (var place = 0; place < watch.length; place++) {
      if ((best ^ ring) & (1 << place) != 0) return place;
    }
    return null;
  }
}
