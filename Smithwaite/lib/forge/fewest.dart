/// The two answers: the walk of every state, and the smith's count.
///
/// The walk is breadth first from the freed bar over every way the rings
/// can lie, using only the moves the cords allow. It knows nothing about
/// arithmetic.
///
/// The smith's count reads the rings as a number without playing a single
/// move: from the top ring down, keep a running tally, and for each ring
/// double the tally and add one when the ring's state differs from the
/// tally's own parity... said plainly, the ring pattern is a Gray code, and
/// decoding it gives exactly how many moves the bar is from free. That the
/// decode equals the walk on every state of nine rings is the anchor test.
///
/// One more fact makes the game what it is: every state has at most two
/// moves, so the whole puzzle is a single path with the freed bar at one
/// end. There is one move forward and one move back, never a third choice,
/// and a test counts the neighbours of every state to prove it.
class Moves {
  const Moves._();

  static final _walks = <int, List<int>>{};

  /// Distance-to-free for every state of [rings] rings, by the walk.
  static List<int> walk(int rings) => _walks.putIfAbsent(rings, () {
        final states = 1 << rings;
        final far = List<int>.filled(states, -1);
        far[0] = 0;
        var edge = [0];
        var away = 0;
        while (edge.isNotEmpty) {
          away++;
          final next = <int>[];
          for (final state in edge) {
            for (final other in moves(rings, state)) {
              if (far[other] != -1) continue;
              far[other] = away;
              next.add(other);
            }
          }
          edge = next;
        }
        return far;
      });

  /// The states one legal move from [state].
  static List<int> moves(int rings, int state) {
    final out = [state ^ 1];
    for (var ring = 1; ring < rings; ring++) {
      final before = state & ((1 << ring) - 1);
      if (before == 1 << (ring - 1)) {
        out.add(state ^ (1 << ring));
        break;
      }
    }
    return out;
  }

  /// Whether [ring] may move in [state]: the first always, any other only
  /// when the ring before it is on and every ring before that is off.
  static bool mayMove(int rings, int state, int ring) {
    if (ring < 0 || ring >= rings) return false;
    if (ring == 0) return true;
    return state & ((1 << ring) - 1) == 1 << (ring - 1);
  }

  /// How far the bar is from free, by the smith's count: the ring pattern
  /// read as a Gray code and decoded, top ring first.
  static int bySmith(int rings, int state) {
    var tally = 0;
    for (var ring = rings - 1; ring >= 0; ring--) {
      final on = (state >> ring) & 1;
      tally = tally * 2 + (on == tally % 2 ? 0 : 1);
    }
    return tally;
  }

  /// The fewest moves from every ring on, by the walk.
  static int fromStart(int rings) => walk(rings)[(1 << rings) - 1];
}
