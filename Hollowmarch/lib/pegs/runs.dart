import 'field.dart';
import 'solve.dart';

/// The fewest *moves* a board can be finished in.
///
/// A move is one peg jumping, once or several times running — which is how
/// the game has always been counted, and it is the only number here worth
/// competing over. The number of jumps is not: every jump takes one peg off,
/// so a board of n pegs always takes n-1 of them whatever anybody does.
///
/// It is a breadth-first walk over positions, with one step of the walk being
/// a whole run rather than a single jump. Positions are numbers and two ways
/// of reaching one are the same thing, so the walk is over a set that is
/// small enough to hold — on the boards this is used for, a few hundred
/// thousand.
class Runs {
  const Runs._();

  /// Every position one run can reach, and how the run went.
  static Map<int, List<Jump>> after(Field field, int pegs) {
    final found = <int, List<Jump>>{};

    void carryOn(int now, List<Jump> so, int peg) {
      for (final jump in field.jumpsFrom(peg)) {
        if (!Solver.canJump(now, jump)) continue;
        final next = Solver.after(now, jump);
        final went = [...so, jump];
        found[next] ??= went;
        carryOn(next, went, jump.to);
      }
    }

    for (var hollow = 0; hollow < field.hollows; hollow++) {
      if (pegs & (1 << hollow) == 0) continue;
      carryOn(pegs, const [], hollow);
    }
    return found;
  }

  /// The fewest moves from here to one peg, and one way of doing it, or null
  /// if there is no way at all.
  ///
  /// [give] is how many positions it may look at before giving up. A board
  /// small enough to answer answers in a moment; the big one is not asked.
  static (int, List<Jump>)? fewest(
    Field field,
    int pegs, {
    int finishAt = -1,
    int give = 4000000,
  }) {
    final came = <int, (int, List<Jump>)>{pegs: (-1, const [])};
    var edge = <int>[pegs];
    var moves = 0;

    bool isDone(int at) =>
        at != 0 &&
        at & (at - 1) == 0 &&
        (finishAt < 0 || at == 1 << finishAt);

    if (isDone(pegs)) return (0, const []);

    while (edge.isNotEmpty && came.length < give) {
      moves++;
      final next = <int>[];
      for (final at in edge) {
        for (final entry in after(field, at).entries) {
          if (came.containsKey(entry.key)) continue;
          came[entry.key] = (at, entry.value);
          if (isDone(entry.key)) {
            // Walk the way back, and turn it round.
            final jumps = <Jump>[];
            var here = entry.key;
            while (came[here]!.$1 >= 0) {
              jumps.insertAll(0, came[here]!.$2);
              here = came[here]!.$1;
            }
            return (moves, jumps);
          }
          next.add(entry.key);
        }
      }
      edge = next;
    }
    return null;
  }

  /// How many moves a list of jumps is: a run is one peg carrying on from
  /// where it landed.
  static int movesIn(List<Jump> jumps) {
    var moves = 0;
    var last = -1;
    for (final jump in jumps) {
      if (jump.from != last) moves++;
      last = jump.to;
    }
    return moves;
  }
}
