/// A row of three girls, sorted; a day is three rows holding all nine.
typedef Row = List<int>;
typedef Day = List<Row>;

/// The law of the walk: nine girls, rows of three, and every pair
/// walking together exactly once over the days.
class Rules {
  static const girls = 9;

  /// The pair (a, b) with a < b as one number, so pairs can be kept in
  /// a set.
  static int pairKey(int a, int b) => a < b ? a * girls + b : b * girls + a;

  /// The three pairs of a row.
  static List<int> pairsOfRow(Row row) => [
        pairKey(row[0], row[1]),
        pairKey(row[0], row[2]),
        pairKey(row[1], row[2]),
      ];

  /// The nine pairs of a day.
  static Set<int> pairsOfDay(Day day) => {for (final row in day) ...pairsOfRow(row)};

  /// Every way of walking the nine out in three rows of three, rows in
  /// order of their first girl: 280 of them.
  static List<Day> get days {
    _days ??= _buildDays();
    return _days!;
  }

  static List<Day>? _days;

  static List<Day> _buildDays() {
    final out = <Day>[];
    void grow(List<int> left, List<Row> rows) {
      if (left.isEmpty) {
        out.add([for (final r in rows) List.of(r)]);
        return;
      }
      final first = left[0];
      final rest = left.sublist(1);
      for (var i = 0; i < rest.length; i++) {
        for (var j = i + 1; j < rest.length; j++) {
          final row = [first, rest[i], rest[j]];
          final remaining = [for (final g in rest) if (g != rest[i] && g != rest[j]) g];
          rows.add(row);
          grow(remaining, rows);
          rows.removeLast();
        }
      }
    }

    grow(List.generate(girls, (g) => g), []);
    return out;
  }

  /// Whether the days so far repeat no pair.
  static bool noPairTwice(List<Day> days) {
    final seen = <int>{};
    for (final day in days) {
      for (final p in pairsOfDay(day)) {
        if (!seen.add(p)) return false;
      }
    }
    return true;
  }

  /// The pairs met over the days, distinct.
  static Set<int> pairsMet(List<Day> days) => {for (final d in days) ...pairsOfDay(d)};

  /// How many ways [more] further days can be added to [given] with no
  /// pair walking twice, days in order, and the first such completion.
  static (int, List<Day>?) completions(List<Day> given, int more) {
    var count = 0;
    List<Day>? first;
    final used = pairsMet(given);
    final chosen = <Day>[];
    void grow(int left) {
      if (left == 0) {
        count++;
        first ??= [for (final d in chosen) d];
        return;
      }
      for (final day in days) {
        final p = pairsOfDay(day);
        if (p.any(used.contains)) continue;
        used.addAll(p);
        chosen.add(day);
        grow(left - 1);
        chosen.removeLast();
        used.removeAll(p);
      }
    }

    grow(more);
    return (count, first);
  }

  /// Kirkman's own week, built with no search: the nine girls in a
  /// three-by-three, walked by rows, by columns, by one diagonal set
  /// and by the other, which is the affine plane of order three.
  static List<Day> get affineWeek => [
        [for (var r = 0; r < 3; r++) [for (var c = 0; c < 3; c++) r * 3 + c]],
        [for (var c = 0; c < 3; c++) [for (var r = 0; r < 3; r++) r * 3 + c]],
        [for (var k = 0; k < 3; k++) ([for (var r = 0; r < 3; r++) r * 3 + (k + r) % 3]..sort())],
        [for (var k = 0; k < 3; k++) ([for (var r = 0; r < 3; r++) r * 3 + (k - r + 3) % 3]..sort())],
      ];

  /// A girl walks with two new girls each day, so a week of every pair
  /// once takes exactly (girls - 1) / 2 days.
  static int get daysNeeded => (girls - 1) ~/ 2;
}
