/// A ring of five beats, and a rack of throws to be laid on them.
///
/// A throw of height h laid on beat i sends its ball up to come down at
/// beat i plus h, counted round the ring. Two balls coming down on the
/// same beat is a drop, so a rack juggles exactly when the landing beats
/// are all different, which makes them a rearrangement of the beats
/// themselves.
///
/// Everything here is whole numbers. The one quantity that can come out
/// a fraction is the balls in the air, and that is exactly what the last
/// ask turns on, so it is kept as a top and a bottom and never divided.
class Rules {
  /// Beats round the ring.
  static const beats = 5;

  /// Where the ball thrown from [beat] at height [height] comes down.
  static int lands(int beat, int height) => (beat + height) % beats;

  /// Whether a full rack of throws juggles: every ball comes down on a
  /// beat of its own.
  static bool juggles(List<int> throws) {
    var seen = 0;
    for (var i = 0; i < throws.length; i++) {
      final at = lands(i, throws[i]);
      if (seen >> at & 1 == 1) return false;
      seen |= 1 << at;
    }
    return true;
  }

  /// The beats the balls come down on, in order of the beat thrown from.
  static List<int> landings(List<int> throws) =>
      [for (var i = 0; i < throws.length; i++) lands(i, throws[i])];

  /// The beats two or more balls come down on.
  static List<int> clashes(List<int> throws) {
    final count = List.filled(beats, 0);
    for (var i = 0; i < throws.length; i++) {
      if (throws[i] < 0) continue;
      count[lands(i, throws[i])]++;
    }
    return [
      for (var b = 0; b < beats; b++)
        if (count[b] > 1) b,
    ];
  }

  /// The first voice on how many balls a rack keeps up: it counts the
  /// throws and divides by the beats, which is the theorem's own claim
  /// and comes out whole only when the total goes round evenly.
  static int total(List<int> throws) {
    var n = 0;
    for (final t in throws) {
      if (t > 0) n += t;
    }
    return n;
  }

  /// The second voice, which knows nothing of averages. It watches the
  /// pattern run and counts the balls still up in the air after each
  /// beat: a ball thrown at beat j comes down at j plus its height, so
  /// after beat k the ones still aloft are those thrown at or before k
  /// and coming down later. The pattern runs from long before k, so the
  /// looking back reaches a whole top height.
  ///
  /// On a rack that juggles this count is the same after every beat; on
  /// one that does not it wobbles. Either way it never mentions the
  /// average.
  static List<int> aloft(List<int> throws) {
    var top = 0;
    for (final t in throws) {
      if (t > top) top = t;
    }
    final out = <int>[];
    for (var k = 0; k < beats; k++) {
      var up = 0;
      for (var j = k - top; j <= k; j++) {
        final h = throws[j % beats < 0 ? j % beats + beats : j % beats];
        if (h > 0 && j + h > k) up++;
      }
      out.add(up);
    }
    return out;
  }

  /// Whether the balls in the air hold steady beat by beat, which the
  /// watching voice uses to decide whether a rack juggles at all.
  static bool steady(List<int> throws) {
    final up = aloft(throws);
    for (final n in up) {
      if (n != up.first) return false;
    }
    return true;
  }

  /// Every different way of laying a rack of throws on the beats.
  static List<List<int>> orderings(List<int> rack) {
    final out = <List<int>>{};
    final sorted = [...rack]..sort();
    void walk(List<int> so, List<bool> used) {
      if (so.length == sorted.length) {
        out.add([...so]);
        return;
      }
      for (var i = 0; i < sorted.length; i++) {
        if (used[i]) continue;
        if (i > 0 && sorted[i] == sorted[i - 1] && !used[i - 1]) continue;
        used[i] = true;
        walk([...so, sorted[i]], used);
        used[i] = false;
      }
    }

    walk(const [], List.filled(sorted.length, false));
    return out.toList();
  }

  /// The orderings of a rack that juggle.
  static List<List<int>> ways(List<int> rack) =>
      [for (final o in orderings(rack)) if (juggles(o)) o];

  /// A rack turned round the ring by one beat, which sends a pattern to
  /// a pattern and is why every count of ways divides by the beats.
  static List<int> turn(List<int> throws) =>
      [for (var i = 0; i < throws.length; i++) throws[(i + 1) % beats]];

  /// The third voice, and one that lays nothing out at all: the number
  /// of patterns of [n] beats keeping exactly [balls] balls up is the
  /// balls plus one, raised to the beats, less the balls raised to the
  /// beats. Any throw in such a pattern is at most balls times beats, so
  /// the count is finite and this closed form has it exactly.
  static int byFormula(int n, int balls) {
    var high = 1, low = 1;
    for (var k = 0; k < n; k++) {
      high *= balls + 1;
      low *= balls;
    }
    return high - low;
  }

  /// Every rack of [n] throws with heights up to [top], as sorted lists.
  static List<List<int>> racks(int n, int top) {
    final out = <List<int>>[];
    void walk(int from, List<int> so) {
      if (so.length == n) {
        out.add([...so]);
        return;
      }
      for (var h = from; h <= top; h++) {
        walk(h, [...so, h]);
      }
    }

    walk(0, const []);
    return out;
  }
}
