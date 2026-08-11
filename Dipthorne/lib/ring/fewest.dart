/// The safe seat, three ways that share nothing.
///
/// The count is the referee: stand the ring up and chant it out, child by
/// child, exactly as the yard does it. The reckoning is the old recurrence:
/// one child in a ring of one is safe at the start, and a ring of n is a
/// ring of n minus one wearing different numbers, so the safe seat moves up
/// by the rhyme's beats and wraps. The two must agree for every size of
/// ring and every rhyme, and a test sweeps them both.
///
/// For a two-beat rhyme there is a third voice, the famous one: write the
/// ring's size in binary, move the front figure to the back, and that is
/// the safe seat. It is checked against the other two for every ring up to
/// five hundred.
class Dips {
  const Dips._();

  /// The safe seat by running the count: a ring of [children], a rhyme of
  /// [beats], counting from seat 1. Seats are 1-counted.
  static int byCount(int children, int beats) {
    final standing = [for (var seat = 1; seat <= children; seat++) seat];
    var from = 0;
    while (standing.length > 1) {
      from = (from + beats - 1) % standing.length;
      standing.removeAt(from);
      if (from == standing.length) from = 0;
    }
    return standing.single;
  }

  /// The order the count sends children out, by running it. Seats
  /// 1-counted; the safe seat is the one not in the list.
  static List<int> outs(int children, int beats) {
    final standing = [for (var seat = 1; seat <= children; seat++) seat];
    final out = <int>[];
    var from = 0;
    while (standing.length > 1) {
      from = (from + beats - 1) % standing.length;
      out.add(standing.removeAt(from));
      if (from == standing.length) from = 0;
    }
    return out;
  }

  /// The safe seat by the reckoning, no count run: the recurrence
  /// J(1) = 0, J(n) = (J(n-1) + beats) mod n, seats 1-counted at the end.
  static int byReckoning(int children, int beats) {
    var safe = 0;
    for (var ring = 2; ring <= children; ring++) {
      safe = (safe + beats) % ring;
    }
    return safe + 1;
  }

  /// The safe seat for a two-beat rhyme by the binary turn: the ring's
  /// size written in binary with the front figure moved to the back.
  static int byBinaryTurn(int children) {
    var top = 1;
    while (top * 2 <= children) {
      top *= 2;
    }
    return (children - top) * 2 + 1;
  }
}
