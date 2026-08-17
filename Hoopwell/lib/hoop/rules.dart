/// A hoop of seven holes, two rings of stones laid in them, and the
/// lamps their sums light.
///
/// Holes are numbered 0 to 6 round the hoop and counting past 6 comes
/// back to 0. Dark stones make one set, pale stones another, and a lamp
/// at hole c lights when c is a dark hole plus a pale hole, counted
/// round.
///
/// A set of holes is a bitmask, so everything here is whole numbers and
/// counting. Nothing is rounded and nothing is approximate.
class Rules {
  /// Holes round the hoop. Seven is a prime, which is the whole point:
  /// the floor below only holds because it is.
  static const holes = 7;

  static int get every => (1 << holes) - 1;

  /// How many stones a set holds.
  static int count(int set) {
    var n = 0;
    for (var h = 0; h < holes; h++) {
      if (set >> h & 1 == 1) n++;
    }
    return n;
  }

  static List<int> at(int set) => [
        for (var h = 0; h < holes; h++)
          if (set >> h & 1 == 1) h,
      ];

  static String write(int set) => at(set).join('');

  /// The first voice, and the one a tap performs. The lamps are the
  /// pale ring laid down again once for each dark stone, turned round
  /// the hoop by that stone's hole, and all of those piled together.
  static int lamps(int dark, int pale) {
    var lit = 0;
    for (final a in at(dark)) {
      lit |= turn(pale, a);
    }
    return lit;
  }

  /// A set turned [by] holes round the hoop.
  static int turn(int set, int by) {
    var out = 0;
    for (final h in at(set)) {
      out |= 1 << ((h + by) % holes);
    }
    return out;
  }

  /// The second voice, which pours rather than piles: it multiplies the
  /// two rings out as counts, so it knows how many ways each lamp is
  /// lit rather than only that it is. The lamps are the holes with a
  /// count above nothing, and the counts add up to the two sets
  /// multiplied, which is a check the first voice cannot make.
  static List<int> ways(int dark, int pale) {
    final out = List.filled(holes, 0);
    for (final a in at(dark)) {
      for (final b in at(pale)) {
        out[(a + b) % holes]++;
      }
    }
    return out;
  }

  static int lampsByWays(int dark, int pale) {
    var lit = 0;
    final w = ways(dark, pale);
    for (var h = 0; h < holes; h++) {
      if (w[h] > 0) lit |= 1 << h;
    }
    return lit;
  }

  /// The floor: with a hoop of a prime number of holes, the lamps can
  /// never come to fewer than the two stone counts added and one taken
  /// off, or the whole hoop if that is smaller. Cauchy proved it in
  /// 1813 and Davenport, who had proved it again in 1935, found
  /// Cauchy's proof in 1947.
  static int floor(int darkCount, int paleCount) {
    if (darkCount == 0 || paleCount == 0) return 0;
    final want = darkCount + paleCount - 1;
    return want < holes ? want : holes;
  }

  /// The third voice, which lights no lamp and turns nothing. On a hoop
  /// of [n] holes the fewest lamps two sets of these sizes can leave is
  /// read off the divisors of n, because a set that sits inside the
  /// multiples of a divisor is the only way to do better than the
  /// floor. When n is prime its only divisors are 1 and n, and the
  /// reading comes back to the floor itself.
  static int floorByDivisors(int n, int darkCount, int paleCount) {
    var least = n;
    for (var d = 1; d <= n; d++) {
      if (n % d != 0) continue;
      final blocks = ((darkCount + d - 1) ~/ d) + ((paleCount + d - 1) ~/ d) - 1;
      final here = blocks * d;
      if (here < least) least = here;
    }
    return least < n ? least : n;
  }

  /// The step between the two dark stones, which is the walk the finger
  /// proof takes. Only asked of a board with exactly two dark stones.
  static int step(int dark) {
    final holesOf = at(dark);
    return (holesOf[1] - holesOf[0]) % holes;
  }

  /// The holes in the order the step visits them, starting at the first
  /// dark stone. On a hoop of a prime number of holes any step but
  /// nothing visits every hole, which is what makes the walk a proof.
  static List<int> walk(int dark) {
    final from = at(dark).first, by = step(dark);
    return [for (var k = 0; k < holes; k++) (from + k * by) % holes];
  }

  /// How many runs of pale stones the walk passes, counted by their
  /// last stone. Each one costs a lamp beyond the pale stones
  /// themselves, because the hole a step past the end of a run lights
  /// and holds no pale stone.
  static int runEnds(int dark, int pale) {
    final order = walk(dark);
    var ends = 0;
    for (var k = 0; k < holes; k++) {
      final here = pale >> order[k] & 1 == 1;
      final next = pale >> order[(k + 1) % holes] & 1 == 1;
      if (here && !next) ends++;
    }
    return ends;
  }

  /// The last stone of each run of pale stones along the walk.
  static List<int> ends(int dark, int pale) {
    final order = walk(dark);
    return [
      for (var k = 0; k < holes; k++)
        if (pale >> order[k] & 1 == 1 && pale >> order[(k + 1) % holes] & 1 == 0)
          order[k],
    ];
  }

  /// Where the board opens: one dark stone and one pale stone, both in
  /// hole 0. It lands none of the asks.
  static const opening = (1, 1);

  /// The taps between two boards, one for each hole that has to change.
  static int between((int, int) from, (int, int) to) =>
      count(from.$1 ^ to.$1) + count(from.$2 ^ to.$2);

  /// Whether a set is a run of holes at a single step, which is what
  /// every board that sits exactly on the floor turns out to be.
  static bool isRun(int set, int by) {
    final n = count(set);
    if (n <= 1) return true;
    for (final start in at(set)) {
      var made = 0;
      for (var k = 0; k < n; k++) {
        made |= 1 << ((start + k * by) % holes);
      }
      if (made == set) return true;
    }
    return false;
  }
}
