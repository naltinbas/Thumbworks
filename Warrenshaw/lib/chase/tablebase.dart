import 'chart.dart';

/// Every position of the chase, settled.
///
/// A position is where the seeker is, where the runner is, and whose turn it
/// is. That is n² of them for each turn, and n is a dozen, so the whole game
/// fits in a few hundred numbers and there is no reason to search anything at
/// run time: it is worked out once and read.
///
/// The number kept is how many more moves the **seeker** needs, playing as
/// well as it can, against a runner playing as well as it can. The seeker is
/// trying to make it small and the runner is trying to make it large, which
/// is the whole of the game and the whole of this file.
///
/// It is worked out backwards, from the end. Everything starts at "never",
/// and a position only ever comes down: a seeker's turn takes the best of
/// what it can reach, a runner's turn takes the worst. Doing that over and
/// over until nothing changes is the answer — a position that stays at
/// "never" is one the runner really does get away with, because if there were
/// a way to catch them, that way would have brought it down.
class Tablebase {
  Tablebase(this.chart) {
    final places = chart.count;
    _seekerToMove = List.filled(places * places, never);
    _runnerToMove = List.filled(places * places, never);

    // Caught. The chase is over wherever the two are in the same place, and
    // no more seeker moves are needed.
    for (var where = 0; where < places; where++) {
      _seekerToMove[where * places + where] = 0;
      _runnerToMove[where * places + where] = 0;
    }

    var changed = true;
    var rounds = 0;
    while (changed) {
      changed = false;
      rounds++;

      for (var seeker = 0; seeker < places; seeker++) {
        for (var runner = 0; runner < places; runner++) {
          if (seeker == runner) continue;
          final at = seeker * places + runner;

          // The seeker moves, and takes the best it can find. Stepping onto
          // the runner is one move and done.
          var best = never;
          for (final next in chart.beside[seeker]) {
            final after = next == runner ? 0 : _runnerToMove[next * places + runner];
            if (after == never) continue;
            if (after + 1 < best) best = after + 1;
          }
          if (best < _seekerToMove[at]) {
            _seekerToMove[at] = best;
            changed = true;
          }

          // The runner moves, and takes the worst the seeker can be left
          // with. Every one of its choices has to be settled before this is:
          // one unsettled choice is one the runner might yet get away with.
          var worst = 0;
          for (final next in chart.beside[runner]) {
            final after =
                next == seeker ? 0 : _seekerToMove[seeker * places + next];
            if (after == never) {
              worst = never;
              break;
            }
            if (after > worst) worst = after;
          }
          if (worst < _runnerToMove[at]) {
            _runnerToMove[at] = worst;
            changed = true;
          }
        }
      }
    }
    this.rounds = rounds;
  }

  /// What a position worth nothing is called. Bigger than any real answer,
  /// so the arithmetic above needs no special cases.
  static const never = 1 << 30;

  final Chart chart;

  late final List<int> _seekerToMove;
  late final List<int> _runnerToMove;

  /// How many times the whole table had to be gone over. Kept because it is
  /// the one number that says whether this is expensive, and it never is.
  late final int rounds;

  /// How many more moves the seeker needs from here, or [never].
  int movesFrom(int seeker, int runner, {required bool seekersTurn}) =>
      (seekersTurn ? _seekerToMove : _runnerToMove)[seeker * chart.count + runner];

  bool isCaught(int seeker, int runner) => seeker == runner;

  /// Whether the seeker can win from here at all.
  bool canCatch(int seeker, int runner, {required bool seekersTurn}) =>
      movesFrom(seeker, runner, seekersTurn: seekersTurn) != never;

  /// The best move for the seeker: the one that leaves the fewest moves to
  /// go. Ties are broken by the place's number, so the same position always
  /// gives the same advice.
  int? bestForSeeker(int seeker, int runner) {
    if (isCaught(seeker, runner)) return null;
    var best = never;
    int? chosen;
    for (final next in chart.beside[seeker]) {
      final after = next == runner
          ? 0
          : movesFrom(next, runner, seekersTurn: false);
      if (after == never) continue;
      if (after + 1 < best) {
        best = after + 1;
        chosen = next;
      }
    }
    return chosen;
  }

  /// The best move for the runner: the one that leaves the most moves to go,
  /// and any escape at all before any number of moves.
  int? bestForRunner(int seeker, int runner) {
    if (isCaught(seeker, runner)) return null;
    var worst = -1;
    int? chosen;
    for (final next in chart.beside[runner]) {
      final after =
          next == seeker ? 0 : movesFrom(seeker, next, seekersTurn: true);
      if (after == never) return next;
      if (after > worst) {
        worst = after;
        chosen = next;
      }
    }
    return chosen;
  }

  /// Whether the seeker wins wherever the runner starts, given the best place
  /// to start from. This is the question the old theorem answers.
  bool get isSeekerWin => bestStart != null;

  /// The place to start from that catches a runner starting anywhere, or null
  /// if there is none.
  int? get bestStart {
    for (var seeker = 0; seeker < chart.count; seeker++) {
      var everywhere = true;
      for (var runner = 0; runner < chart.count && everywhere; runner++) {
        if (!canCatch(seeker, runner, seekersTurn: true)) everywhere = false;
      }
      if (everywhere) return seeker;
    }
    return null;
  }

  /// The longest the runner can last, from the best place for the seeker to
  /// start and the best place for the runner to start against it.
  int get capture {
    final start = bestStart;
    if (start == null) return never;
    var worst = 0;
    for (var runner = 0; runner < chart.count; runner++) {
      final moves = movesFrom(start, runner, seekersTurn: true);
      if (moves > worst) worst = moves;
    }
    return worst;
  }
}
