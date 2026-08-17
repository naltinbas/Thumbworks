/// Eight boxes laid in a staircase: rows left aligned, each row no
/// longer than the one above it. A filling numbers the boxes 1 to 8 so
/// that the numbers rise along every row and down every column.
///
/// The number of fillings is eight factorial divided by the product of
/// the hooks, where a box's hook is itself, plus the boxes to its right
/// in its row, plus the boxes below it in its column. Frame, Robinson
/// and Thrall published that in 1954.
class Rules {
  /// The boxes a staircase holds.
  static const boxes = 8;

  /// The staircase a go opens on.
  static const opening = [3, 3, 2];

  static int factorial(int n) {
    var out = 1;
    for (var k = 2; k <= n; k++) {
      out *= k;
    }
    return out;
  }

  /// Whether the rows make a staircase: none empty, none longer than
  /// the one above, and eight boxes in all.
  static bool valid(List<int> rows) {
    if (rows.isEmpty) return false;
    var total = 0;
    for (var i = 0; i < rows.length; i++) {
      if (rows[i] < 1) return false;
      if (i > 0 && rows[i] > rows[i - 1]) return false;
      total += rows[i];
    }
    return total == boxes;
  }

  /// How many boxes stand under a column, counting the rows that reach
  /// it.
  static int down(List<int> rows, int column) {
    var out = 0;
    for (final row in rows) {
      if (row > column) out++;
    }
    return out;
  }

  /// The hook of the box at [row], [column]: itself, the boxes to its
  /// right, and the boxes below it.
  static int hook(List<int> rows, int row, int column) =>
      rows[row] - column + down(rows, column) - row - 1;

  /// Every hook in the staircase, row by row.
  static List<int> hooks(List<int> rows) => [
        for (var r = 0; r < rows.length; r++)
          for (var c = 0; c < rows[r]; c++) hook(rows, r, c),
      ];

  /// The hooks multiplied together.
  static int hookProduct(List<int> rows) {
    var out = 1;
    for (final h in hooks(rows)) {
      out *= h;
    }
    return out;
  }

  /// The first voice: eight factorial over the product of the hooks,
  /// which counts nothing.
  static int byHooks(List<int> rows) =>
      factorial(boxes) ~/ hookProduct(rows);

  /// The second voice: the fillings counted one at a time, by taking
  /// the largest number off a corner and counting what is left.
  static int byCounting(List<int> rows) => _count(_key(rows), {});

  static String _key(List<int> rows) => rows.join(',');

  static int _count(String key, Map<String, int> held) {
    if (key.isEmpty) return 1;
    final at = held[key];
    if (at != null) return at;
    final rows = [for (final r in key.split(',')) int.parse(r)];
    var out = 0;
    for (var i = 0; i < rows.length; i++) {
      // The largest number can only sit on a corner: the end of a row
      // that is longer than the row below it.
      if (i + 1 < rows.length && rows[i + 1] == rows[i]) continue;
      final less = [
        for (var j = 0; j < rows.length; j++)
          if (j == i) rows[j] - 1 else rows[j],
      ]..removeWhere((r) => r == 0);
      out += _count(_key(less), held);
    }
    held[key] = out;
    return out;
  }

  /// The rows a box can be lifted off: the end of a row longer than the
  /// row below it.
  static List<int> corners(List<int> rows) => [
        for (var i = 0; i < rows.length; i++)
          if (i + 1 >= rows.length || rows[i + 1] < rows[i]) i,
      ];

  /// Where a lifted box can be dropped: a row it can lengthen without
  /// passing the row above, or a new row at the foot.
  static List<int> landings(List<int> rows) => [
        for (var i = 0; i < rows.length; i++)
          if (i == 0 || rows[i - 1] > rows[i]) i,
        rows.length,
      ];

  /// Lifts a box off row [from] and drops it on row [to], where a [to]
  /// past the last row starts a new one.
  static List<int>? move(List<int> rows, int from, int to) {
    if (!corners(rows).contains(from)) return null;
    final off = [
      for (var i = 0; i < rows.length; i++)
        if (i == from) rows[i] - 1 else rows[i],
    ];
    final kept = <int>[];
    var shift = 0;
    for (var i = 0; i < off.length; i++) {
      if (off[i] == 0) {
        if (i < to) shift++;
        continue;
      }
      kept.add(off[i]);
    }
    final at = to - shift;
    if (at < 0 || at > kept.length) return null;
    final out = [...kept];
    if (at == out.length) {
      out.add(1);
    } else {
      out[at]++;
    }
    if (!valid(out)) return null;
    final sorted = [...out]..sort((a, b) => b - a);
    if (sorted.join(',') != out.join(',')) return null;
    return out;
  }

  /// Every staircase eight boxes can be laid in.
  static List<List<int>> staircases() {
    final out = <List<int>>[];
    void build(int left, int most, List<int> so) {
      if (left == 0) {
        out.add(List.of(so));
        return;
      }
      for (var k = left < most ? left : most; k >= 1; k--) {
        build(left - k, k, [...so, k]);
      }
    }

    build(boxes, boxes, const []);
    return out;
  }

  /// The staircase turned on its side, rows for columns.
  static List<int> turned(List<int> rows) =>
      [for (var c = 0; c < rows[0]; c++) down(rows, c)];

  static String tellShape(List<int> rows) => rows.join(', ');
}
