import 'dart:typed_data';

import 'climbs.dart';
import 'graph.dart';

/// Why a word was not allowed on the ladder.
enum Refusal {
  /// It is not in the list.
  notAWord,

  /// It changes none of the letters, or more than one.
  notOneLetter,

  /// It is already on the ladder below, and going back to it is a loop.
  beenThere,
}

/// A climb in progress: the rungs so far, and what is known about them.
///
/// Immutable. Every rung gives a new one, so a test can play a whole climb as
/// an expression and the screen can look back over a list nothing has been
/// able to change.
class Play {
  const Play._({
    required this.climb,
    required this.ladder,
    required this.rungs,
    required this.away,
    required this.refused,
  });

  factory Play.of(Climb climb, Ladder ladder) {
    final to = ladder.numberOf(climb.to);
    return Play._(
      climb: climb,
      ladder: ladder,
      rungs: [ladder.numberOf(climb.from)],
      // How far every word is from the end, worked out once when the climb
      // starts. Everything the game knows about how a player is doing comes
      // out of this one walk.
      away: ladder.stepsFrom(to),
      refused: null,
    );
  }

  final Climb climb;
  final Ladder ladder;

  /// The words climbed so far, the first being the one it started on.
  final List<int> rungs;

  /// How far every word in the list is from the end.
  final Int32List away;

  /// Why the last word offered was turned down, if one was.
  final Refusal? refused;

  String get here => ladder.wordAt(rungs.last);

  List<String> get words => [for (final rung in rungs) ladder.wordAt(rung)];

  bool get isDone => here == climb.to;

  /// How many rungs have been climbed.
  int get taken => rungs.length - 1;

  /// The fewest steps still needed from where the player is standing.
  ///
  /// Exact, not a guess: it is read straight out of the walk done when the
  /// climb started.
  int get stepsLeft => away[rungs.last];

  /// Whether the ladder so far is still one of the shortest there are.
  ///
  /// A player who has taken three rungs and is four from the end on a climb
  /// of five has gone somewhere the shortest way through does not go. Saying
  /// so at once is the difference between a puzzle and ten minutes of walking
  /// in a circle.
  bool get onShortest => taken + stepsLeft == climb.rungs;

  /// How many rungs have been spent going nowhere.
  int get wasted => taken + stepsLeft - climb.rungs;

  /// This climb with a word added, or with a refusal on it.
  Play tried(String word) {
    if (isDone) return this;

    final number = ladder.numberOf(word);
    if (number < 0) return _refusing(Refusal.notAWord);
    if (!_isOneLetterFrom(word, here)) {
      return _refusing(Refusal.notOneLetter);
    }
    if (rungs.contains(number)) return _refusing(Refusal.beenThere);

    return Play._(
      climb: climb,
      ladder: ladder,
      rungs: [...rungs, number],
      away: away,
      refused: null,
    );
  }

  /// This climb with the last rung taken off.
  Play get back => rungs.length < 2
      ? _refusing(null)
      : Play._(
          climb: climb,
          ladder: ladder,
          rungs: rungs.sublist(0, rungs.length - 1),
          away: away,
          refused: null,
        );

  /// The word to go to next, on a shortest ladder from here.
  ///
  /// There is always one while the end can be reached at all, because every
  /// word this far from the end has a neighbour one nearer.
  String? get nextRung {
    if (isDone || stepsLeft < 0) return null;
    for (final next in ladder.nextTo(rungs.last)) {
      if (away[next] == stepsLeft - 1 && !rungs.contains(next)) {
        return ladder.wordAt(next);
      }
    }
    // Every way onwards doubles back on the ladder already climbed. Rare, and
    // the answer is to take a rung off rather than to add one.
    return null;
  }

  Play _refusing(Refusal? why) => Play._(
        climb: climb,
        ladder: ladder,
        rungs: rungs,
        away: away,
        refused: why,
      );

  static bool _isOneLetterFrom(String word, String other) {
    if (word.length != other.length) return false;
    var different = 0;
    for (var at = 0; at < word.length; at++) {
      if (word[at] != other[at]) different++;
    }
    return different == 1;
  }
}
