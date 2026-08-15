import 'dart:math';

/// The arithmetic of the ring: a middle coin, coins of one size set
/// touching it, and how many go round before two of them overlap. Two
/// voices: the angle, each ring coin taking twice the arcsine of its
/// radius over the two radii added, so as many fit as that goes into a
/// full turn; and the measure, the ring coins set at equal angles and
/// the distance between neighbours' centres held against twice their
/// radius.
class Rules {
  /// The dials run from one to this.
  static const most = 6;

  /// How many settings the two dials have between them.
  static const settings = most * most;

  /// The angle one ring coin takes at the middle, in radians: twice the
  /// arcsine of ring over middle plus ring.
  static double span(int middle, int ring) => 2 * asin(ring / (middle + ring));

  /// Whether [count] coins of [ring] fit round [middle] without
  /// overlapping, by the angle. Six is the one count where the two sides
  /// can be equal, coins of a size touching all round, so it is decided
  /// exactly: ring over middle plus ring at most a half. No other count
  /// can tie, the sine of a turn over it being irrational for every
  /// other count from three up, and one or two coins always fit.
  static bool fits(int middle, int ring, int count) {
    if (count <= 2) return true;
    if (count == 6) return 2 * ring <= middle + ring;
    return count * span(middle, ring) <= 2 * pi;
  }

  /// The most coins of [ring] that fit round [middle], by the angle.
  static int mostRound(int middle, int ring) {
    var k = 1;
    while (fits(middle, ring, k + 1)) {
      k++;
    }
    return k;
  }

  /// The most, by the measure: the ring coins set at equal angles round
  /// the middle, and the count raised until two neighbours' centres come
  /// nearer than twice the ring's radius; the tie of six equal coins is
  /// let through by a hair.
  static int mostMeasured(int middle, int ring) {
    var k = 1;
    while (true) {
      final next = k + 1;
      final (ax, ay) = centre(middle, ring, next, 0);
      final (bx, by) = centre(middle, ring, next, 1);
      final gap = sqrt((ax - bx) * (ax - bx) + (ay - by) * (ay - by));
      if (gap + 1e-9 < 2 * ring) return k;
      k = next;
    }
  }

  /// The centre of ring coin [i] of [count] set at equal angles, the
  /// first at the top, going clockwise, in units.
  static (double, double) centre(int middle, int ring, int count, int i) {
    final a = 2 * pi * i / count;
    return ((middle + ring) * sin(a), (middle + ring) * cos(a));
  }

  /// The turn left over once the most coins are set, in degrees; six
  /// equal coins leave nothing, and a hair of rounding is not a gap.
  static double spare(int middle, int ring) {
    final left = 360 - mostRound(middle, ring) * span(middle, ring) * 180 / pi;
    return left.abs() < 1e-9 ? 0 : left;
  }

  /// Sweeps every setting of the two dials: how many meet [ask], how many
  /// there are, and the first that meets it, the middle climbing slowest.
  static (int, int, (int, int)?) sweep(bool Function(int middle, int ring) ask) {
    var met = 0, all = 0;
    (int, int)? first;
    for (var middle = 1; middle <= most; middle++) {
      for (var ring = 1; ring <= most; ring++) {
        all++;
        if (ask(middle, ring)) {
          met++;
          first ??= (middle, ring);
        }
      }
    }
    return (met, all, first);
  }

  static const _words = ['no', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen'];

  static String count(int n) => n >= 0 && n < _words.length ? _words[n] : '$n';
}
