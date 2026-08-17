/// A strip of beads, each light or dark. A repeat of p means the strip
/// reads the same p beads along: bead i and bead i + p match, as far as
/// the strip goes.
///
/// Fine and Wilf's theorem, from Nathan Fine and Herbert Wilf in 1965:
/// a strip with repeats p and q that is at least p + q less their
/// greatest common divisor beads long has that divisor as a repeat too.
/// The length is sharp. One bead shorter and there are strips with both
/// repeats and not the divisor, and the shortest of them are the
/// Fibonacci-like strips.
class Rules {
  /// The beads a strip may hold.
  static const light = 0, dark = 1;

  /// The strips the game uses.
  static const shortest = 2, longest = 12;

  /// Whether the strip repeats every [p] beads.
  static bool repeats(List<int> strip, int p) {
    for (var i = 0; i + p < strip.length; i++) {
      if (strip[i] != strip[i + p]) return false;
    }
    return true;
  }

  /// The same asked the other way about: a strip repeats every p when
  /// its first beads and its last beads match over the overlap, which
  /// is what a border is. Nothing here compares bead i with bead i + p.
  static bool repeatsByBorder(List<int> strip, int p) {
    final over = strip.length - p;
    if (over <= 0) return true;
    final head = strip.sublist(0, over);
    final tail = strip.sublist(p);
    for (var i = 0; i < over; i++) {
      if (head[i] != tail[i]) return false;
    }
    return true;
  }

  /// Every repeat the strip has, from one bead up to its length.
  static List<int> periodsOf(List<int> strip) => [
        for (var p = 1; p <= strip.length; p++)
          if (repeats(strip, p)) p,
      ];

  static int gcdOf(int a, int b) {
    while (b != 0) {
      final held = b;
      b = a % b;
      a = held;
    }
    return a;
  }

  /// The length at which two repeats force their greatest common
  /// divisor: p plus q less that divisor.
  static int bound(int p, int q) => p + q - gcdOf(p, q);

  /// Every strip of [beads] beads.
  static Iterable<List<int>> strips(int beads) sync* {
    for (var mask = 0; mask < (1 << beads); mask++) {
      yield [
        for (var i = 0; i < beads; i++) mask >> i & 1,
      ];
    }
  }

  static int howManyStrips(int beads) => 1 << beads;

  /// A strip told in letters: 'L D L L'.
  static String tellStrip(List<int> strip) =>
      strip.map((bead) => bead == light ? 'L' : 'D').join(' ');

  static String tellPeriods(List<int> periods) => periods.join(', ');

  /// A count with a comma every three figures.
  static String tellCount(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}
