/// The law of the alley.
///
/// Skittles stand in rows. A knock takes one skittle, or two standing
/// shoulder to shoulder, and may split a row in two. Whoever knocks
/// the last skittle wins.
///
/// Who has a position is known two ways that share nothing: a search
/// of every position, move by move, and the old skittle arithmetic,
/// which counts each row and adds the counts the carry-less way. The
/// suite sweeps both over every position that fits an alley and they
/// never part.
class Rules {
  /// The count of a single row, by the little-known rule: every way of
  /// knocking splits the row, and the row's count is the least number
  /// none of the splits reach.
  static final _counts = <int, int>{0: 0};

  static int countOf(int row) => _counts[row] ??= () {
        final reached = <int>{};
        for (var take = 1; take <= 2 && take <= row; take++) {
          for (var left = 0; left * 2 <= row - take; left++) {
            reached.add(countOf(left) ^ countOf(row - take - left));
          }
        }
        var least = 0;
        while (reached.contains(least)) {
          least++;
        }
        return least;
      }();

  /// The whole alley's count: the rows' counts, added carry-less.
  static int countAlley(List<int> rows) {
    var count = 0;
    for (final row in rows) {
      count ^= countOf(row);
    }
    return count;
  }

  /// Whether the mover wins, by search alone. Rows sorted, empty rows
  /// dropped, memoised on the shape.
  static final _won = <String, bool>{};

  static List<int> tidy(List<int> rows) =>
      ([for (final row in rows) if (row > 0) row]..sort());

  static bool moverWins(List<int> rows) {
    final shape = tidy(rows);
    if (shape.isEmpty) return false;
    final key = shape.join(',');
    final known = _won[key];
    if (known != null) return known;
    var wins = false;
    for (final next in moves(shape)) {
      if (!moverWins(next)) {
        wins = true;
        break;
      }
    }
    return _won[key] = wins;
  }

  /// Every position one knock away.
  static List<List<int>> moves(List<int> rows) {
    final out = <List<int>>[];
    final seen = <String>{};
    for (var at = 0; at < rows.length; at++) {
      final row = rows[at];
      final rest = [
        for (var other = 0; other < rows.length; other++)
          if (other != at) rows[other],
      ];
      for (var take = 1; take <= 2 && take <= row; take++) {
        for (var left = 0; left <= row - take; left++) {
          final next = tidy([...rest, left, row - take - left]);
          final key = next.join(',');
          if (seen.add(key)) out.add(next);
        }
      }
    }
    return out;
  }

  /// Every alley shape holding at most so many skittles.
  static Iterable<List<int>> shapes(int most) sync* {
    yield* _shapes(most, 1, const []);
  }

  static Iterable<List<int>> _shapes(
      int left, int least, List<int> held) sync* {
    if (held.isNotEmpty) yield held;
    for (var row = least; row <= left; row++) {
      yield* _shapes(left - row, row, [...held, row]);
    }
  }
}
