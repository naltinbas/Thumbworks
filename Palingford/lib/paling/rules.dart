/// A fence of ten palings, no two the same height, and the runs that go up
/// and down it.
///
/// A climb is a set of palings, read left to right, each taller than the one
/// before. A drop is the same reading downhill. Neither has to be a stretch
/// of neighbours: any palings will do so long as they come in that order
/// along the fence.
///
/// Everything here is whole numbers. No height is ever compared as anything
/// but one whole number against another.
class Rules {
  /// Palings in the fence.
  static const palings = 10;

  /// The fence as the carter left it: shortest at the near end, tallest at
  /// the far end. One climb the whole way and no drop at all.
  static List<int> get opening => [for (var h = 1; h <= palings; h++) h];

  /// The longest climb ending at each paling, place by place.
  static List<int> climbs(List<int> fence) {
    final so = List.filled(fence.length, 1);
    for (var i = 0; i < fence.length; i++) {
      for (var j = 0; j < i; j++) {
        if (fence[j] < fence[i] && so[j] + 1 > so[i]) so[i] = so[j] + 1;
      }
    }
    return so;
  }

  /// The longest drop ending at each paling, place by place.
  static List<int> drops(List<int> fence) {
    final so = List.filled(fence.length, 1);
    for (var i = 0; i < fence.length; i++) {
      for (var j = 0; j < i; j++) {
        if (fence[j] > fence[i] && so[j] + 1 > so[i]) so[i] = so[j] + 1;
      }
    }
    return so;
  }

  static int _most(List<int> of) {
    var best = 0;
    for (final n in of) {
      if (n > best) best = n;
    }
    return best;
  }

  static int longestClimb(List<int> fence) => _most(climbs(fence));

  static int longestDrop(List<int> fence) => _most(drops(fence));

  /// What is written on a paling's tag: the longest climb ending there and
  /// the longest drop ending there.
  ///
  /// No two palings on a fence carry the same tag. Take any two and look at
  /// the taller of the pair: if it stands to the right of the shorter, its
  /// climb is longer by at least one, and if it stands to the left, the
  /// shorter one's drop is longer by at least one. So the tags are all
  /// different, and that is the whole of the reason a fence of ten cannot
  /// keep both numbers under four.
  static (int, int) badge(List<int> fence, int at) =>
      (climbs(fence)[at], drops(fence)[at]);

  /// One of the longest climbs, as the places it runs through.
  static List<int> climbLine(List<int> fence) => _line(fence, climbs(fence),
      (a, b) => a < b);

  /// One of the longest drops, as the places it runs through.
  static List<int> dropLine(List<int> fence) => _line(fence, drops(fence),
      (a, b) => a > b);

  static List<int> _line(
    List<int> fence,
    List<int> so,
    bool Function(int, int) goes,
  ) {
    var end = 0;
    for (var i = 1; i < fence.length; i++) {
      if (so[i] > so[end]) end = i;
    }
    final places = <int>[end];
    var want = so[end] - 1;
    for (var i = end - 1; i >= 0 && want > 0; i--) {
      if (so[i] == want && goes(fence[i], fence[places.last])) {
        places.add(i);
        want--;
      }
    }
    return places.reversed.toList();
  }

  /// The fence with the paling at [from] pulled out and slid back in at the
  /// gap [into], the rest closing up behind it. This is the player's move
  /// and the only one there is.
  ///
  /// The gaps are numbered from the near end: gap 0 is before the first
  /// paling still standing, gap 9 is past the last. Sliding a paling back
  /// into the gap it came from leaves the fence as it was.
  static List<int> lift(List<int> fence, int from, int into) {
    final rest = [...fence]..removeAt(from);
    rest.insert(into, fence[from]);
    return rest;
  }

  /// The most palings that keep their order across two fences.
  static int shared(List<int> a, List<int> b) {
    final table = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));
    for (var i = 0; i < a.length; i++) {
      for (var j = 0; j < b.length; j++) {
        table[i + 1][j + 1] = a[i] == b[j]
            ? table[i][j] + 1
            : (table[i][j + 1] > table[i + 1][j]
                ? table[i][j + 1]
                : table[i + 1][j]);
      }
    }
    return table[a.length][b.length];
  }

  /// The moves between two fences: every paling that does not keep its
  /// order has to be lifted once, and lifting them in the right sequence is
  /// enough. So it is ten less the palings that keep their order.
  static int between(List<int> a, List<int> b) => palings - shared(a, b);

  /// Every shape a heap of ten can be laid in, rows longest first.
  ///
  /// These are what the second voice counts with. It never writes a fence
  /// down.
  static List<List<int>> shapes([int of = palings]) {
    final out = <List<int>>[];
    void lay(int left, int cap, List<int> so) {
      if (left == 0) {
        out.add([...so]);
        return;
      }
      for (var row = left < cap ? left : cap; row >= 1; row--) {
        lay(left - row, row, [...so, row]);
      }
    }

    lay(of, of, const []);
    return out;
  }

  /// How many ways a shape can be filled in with the numbers one upward so
  /// that every row and every column climbs. This is the hook length
  /// formula: for each cell, count the cells to its right in its row and
  /// below it in its column, add one for itself, multiply the lot, and
  /// divide that into the factorial.
  static int tableaux(List<int> shape) {
    final cells = shape.fold(0, (a, b) => a + b);
    final down = [
      for (var column = 0; column < shape[0]; column++)
        shape.where((row) => row > column).length,
    ];
    var hooks = 1;
    for (var r = 0; r < shape.length; r++) {
      for (var c = 0; c < shape[r]; c++) {
        hooks *= (shape[r] - c) + (down[c] - r) - 1;
      }
    }
    var whole = 1;
    for (var n = 2; n <= cells; n++) {
      whole *= n;
    }
    return whole ~/ hooks;
  }

  /// The second voice: how many fences keep every climb to [climbCap] and
  /// every drop to [dropCap], counted from the shapes alone.
  ///
  /// Robinson and Schensted matched each fence with a pair of filled shapes.
  /// The top row of the shape is the longest climb and the number of rows is
  /// the longest drop, so the fences wanted are the ones whose shape fits in
  /// a box [climbCap] wide and [dropCap] deep, and each shape stands for its
  /// fillings squared. Not one fence is written down to get the number.
  static int byShapes(int climbCap, int dropCap, [int of = palings]) {
    var total = 0;
    for (final shape in shapes(of)) {
      if (shape[0] > climbCap || shape.length > dropCap) continue;
      final ways = tableaux(shape);
      total += ways * ways;
    }
    return total;
  }
}
