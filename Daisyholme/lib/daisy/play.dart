import 'circle.dart';
import 'rules.dart';

/// A circle being befriended. Every state is a fresh value, and
/// the one before hangs on for take-back.
class Play {
  Play._(this.circle, this.rules, this.wired, this.moves, this.before);

  factory Play.of(Circle circle) {
    final rules = Rules(circle.people);
    final wired = List.filled(rules.pairs.length, false);
    for (final pair in circle.given) {
      wired[rules.pairs.indexOf(pair)] = true;
    }
    return Play._(circle, rules, wired, 0, null);
  }

  /// A play stood at a wiring, for the mark and the tests.
  factory Play.standing(Circle circle, List<bool> wired) =>
      Play._(circle, Rules(circle.people), List.of(wired),
          wired.where((wire) => wire).length, null);

  final Circle circle;
  final Rules rules;

  /// One bool per pair: whether they are friends.
  final List<bool> wired;

  /// Befriendings and partings taken, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless circle admits it.
  static const gaveUpAt = 12;

  List<int> get commons => rules.commons(wired);

  /// How many pairs already share exactly one friend.
  int get settled =>
      commons.where((count) => count == 1).length;

  bool get isDone => rules.lands(wired);

  bool get gaveUp => !circle.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Whether a pair's wire may be tapped at all.
  bool turns(int pair) =>
      !isOver &&
      pair >= 0 &&
      pair < rules.pairs.length &&
      !circle.given.contains(rules.pairs[pair]);

  /// Befriends or parts one pair.
  Play flipAt(int pair) {
    if (!turns(pair)) return this;
    final turned = List.of(wired);
    turned[pair] = !turned[pair];
    return Play._(circle, rules, turned, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The pair the show-me points at: a stray wire to part, or
  /// a missing wire of the nearest daisy; null when none lands.
  int? get next {
    if (isOver || !circle.winnable) return null;
    List<bool>? bestAim;
    var nearest = 1 << 30;
    // Every daisy: each heart, each pairing of the rest.
    void offer(List<bool> aim) {
      for (final pair in circle.given) {
        if (!aim[rules.pairs.indexOf(pair)]) return;
      }
      var apart = 0;
      for (var at = 0; at < wired.length; at++) {
        if (wired[at] != aim[at]) apart++;
      }
      if (apart < nearest) {
        nearest = apart;
        bestAim = aim;
      }
    }

    for (var heart = 0; heart < circle.people; heart++) {
      final others = [
        for (var p = 0; p < circle.people; p++)
          if (p != heart) p,
      ];
      void pairUp(List<int> left, List<(int, int)> petals) {
        if (left.isEmpty) {
          final aim = List.filled(rules.pairs.length, false);
          for (final other in others) {
            final pair = heart < other
                ? (heart, other)
                : (other, heart);
            aim[rules.pairs.indexOf(pair)] = true;
          }
          for (final petal in petals) {
            aim[rules.pairs.indexOf(petal)] = true;
          }
          offer(aim);
          return;
        }
        final first = left.first;
        for (var at = 1; at < left.length; at++) {
          final second = left[at];
          pairUp(
            [
              for (final p in left)
                if (p != first && p != second) p,
            ],
            [
              ...petals,
              first < second ? (first, second) : (second, first),
            ],
          );
        }
      }

      pairUp(others, const []);
    }
    final aim = bestAim;
    if (aim == null) return null;
    for (var at = 0; at < wired.length; at++) {
      if (wired[at] && !aim[at]) return at;
    }
    for (var at = 0; at < wired.length; at++) {
      if (!wired[at] && aim[at]) return at;
    }
    return null;
  }
}
