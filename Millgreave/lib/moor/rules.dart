/// The two answers: the built rows, and the search.
///
/// A moor is a square of plots, one windmill wanted in every file, and
/// two mills steal each other's wind when they share a row, a file, or a
/// slant. The search is backtracking file by file, and it counts every
/// way a moor can be set.
///
/// The build is the strange answer: for any moor of four plots or more,
/// a setting can be written straight down, no search in sight. On most
/// sizes the mills step two rows at a time, the evens then the odds; on
/// sizes where that staircase trips, six and eight and their kin by the
/// old remainder rules, a shifted variant steps instead. The tests set
/// the built rows on the moor and check the wind plot by plot.
class Rules {
  const Rules._();

  /// Whether two plots steal each other's wind.
  static bool steals(int fileA, int rowA, int fileB, int rowB) =>
      rowA == rowB ||
      fileA == fileB ||
      (fileA - fileB).abs() == (rowA - rowB).abs();

  /// Every way to set [size] mills, counted by backtracking. Stops early
  /// at [most] when asked.
  static int ways(int size, {int? most}) {
    var found = 0;
    final rows = List<int>.filled(size, -1);
    bool fits(int file, int row) {
      for (var other = 0; other < file; other++) {
        if (steals(other, rows[other], file, row)) return false;
      }
      return true;
    }

    bool walk(int file) {
      if (file == size) {
        found++;
        return most != null && found >= most;
      }
      for (var row = 0; row < size; row++) {
        if (!fits(file, row)) continue;
        rows[file] = row;
        if (walk(file + 1)) return true;
        rows[file] = -1;
      }
      return false;
    }

    walk(0);
    return found;
  }

  /// A setting written straight down: rows[file] for each file, by the
  /// old staircase constructions. Null for moors of two or three plots,
  /// which have none at all.
  static List<int>? built(int size) {
    if (size == 1) return const [0];
    if (size < 4) return null;
    final rows = <int>[];
    final remainder = size % 6;
    if (remainder != 2 && remainder != 3) {
      // Evens climbing, then odds.
      for (var row = 1; row < size; row += 2) {
        rows.add(row);
      }
      for (var row = 0; row < size; row += 2) {
        rows.add(row);
      }
      return rows;
    }
    if (remainder == 2) {
      // The shifted ladder for sizes leaving two by six.
      for (var row = 1; row < size; row += 2) {
        rows.add(row);
      }
      // Odd rows in the order 3, 1, then 7, 9, ... , 5.
      rows.add(2);
      rows.add(0);
      for (var row = 6; row < size; row += 2) {
        rows.add(row);
      }
      rows.add(4);
      return rows;
    }
    // Remainder three: evens from 4 then 0 and 2, odds from 5 then 1, 3.
    for (var row = 3; row < size; row += 2) {
      rows.add(row);
    }
    rows.add(1);
    for (var row = 4; row < size; row += 2) {
      rows.add(row);
    }
    rows.add(0);
    rows.add(2);
    return rows;
  }

  /// Whether a part-set moor can still be finished: mills so far as
  /// rows[file], -1 for files still empty.
  static bool canStillSet(int size, List<int> rows) {
    bool fits(int file, int row) {
      for (var other = 0; other < size; other++) {
        if (other == file || rows[other] < 0) continue;
        if (steals(other, rows[other], file, row)) return false;
      }
      return true;
    }

    bool walk(int file) {
      if (file == size) return true;
      if (rows[file] >= 0) return walk(file + 1);
      for (var row = 0; row < size; row++) {
        if (!fits(file, row)) continue;
        rows[file] = row;
        if (walk(file + 1)) {
          rows[file] = -1;
          return true;
        }
        rows[file] = -1;
      }
      return false;
    }

    return walk(0);
  }
}
