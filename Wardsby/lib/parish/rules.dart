/// The law of the parish: twenty-five households on a five-by-five,
/// each Blue or Red, to be drawn into five wards of five households
/// each, every ward in one piece; a ward goes to the side with three or
/// more of its five, and the vestry to the side with three or more of
/// the five wards. Every drawing there is, 4,006 of them, is walked:
/// the first bare household starts a new ward, and every connected five
/// containing it and no household before it is tried. A side wins a
/// ward only with three votes in it, so a side with fewer than nine
/// votes never wins three wards, however the lines are drawn.
class Rules {
  static const side = 5;
  static const cells = 25;
  static const wards = 5;
  static const wardSize = 5;

  /// The four neighbours of a cell, inside the parish.
  static List<int> neighbours(int c) {
    final x = c % side, y = c ~/ side;
    return [
      if (x > 0) c - 1,
      if (x < side - 1) c + 1,
      if (y > 0) c - side,
      if (y < side - 1) c + side,
    ];
  }

  /// Every drawing: a list of 25 ward numbers, wards numbered in the
  /// order their first household comes. Kept once walked.
  static List<List<int>> get drawings => _drawings ??= _walk();
  static List<List<int>>? _drawings;

  static List<List<int>> _walk() {
    final grid = List.filled(cells, -1);
    final out = <List<int>>[];
    void place(int ward) {
      final start = grid.indexOf(-1);
      if (start < 0) {
        out.add(List.of(grid));
        return;
      }
      // Every connected set of five holding start and nothing before it,
      // over bare households only, each once.
      final sets = <String, List<int>>{};
      void grow(List<int> region) {
        if (region.length == wardSize) {
          final key = (List.of(region)..sort()).join(',');
          sets[key] = List.of(region);
          return;
        }
        for (final c in List.of(region)) {
          for (final n in neighbours(c)) {
            if (n > start && grid[n] == -1 && !region.contains(n)) {
              region.add(n);
              grow(region);
              region.removeLast();
            }
          }
        }
      }

      grow([start]);
      // In order of their households, read as numbers.
      final regions = sets.values.map((r) => List.of(r)..sort()).toList()
        ..sort((a, b) {
          for (var i = 0; i < a.length; i++) {
            if (a[i] != b[i]) return a[i] - b[i];
          }
          return 0;
        });
      for (final region in regions) {
        for (final c in region) {
          grid[c] = ward;
        }
        place(ward + 1);
        for (final c in region) {
          grid[c] = -1;
        }
      }
    }

    place(0);
    return out;
  }

  /// A second walk of the count, by columns of the parish read the
  /// other way about: the same drawings turned, so the same number.
  static int countTurned() {
    // Turn every drawing a quarter and re-key: the set of turned
    // drawings must be the set of drawings, so its size is the count.
    final seen = <String>{};
    for (final d in drawings) {
      final turned = List.filled(cells, -1);
      for (var c = 0; c < cells; c++) {
        final x = c % side, y = c ~/ side;
        // (x, y) -> (side - 1 - y, x)
        turned[x * side + (side - 1 - y)] = d[c];
      }
      seen.add(canonical(turned).join(','));
    }
    return seen.length;
  }

  /// A drawing renumbered so wards come in the order of their first
  /// household.
  static List<int> canonical(List<int> d) {
    final map = <int, int>{};
    final out = List.filled(cells, -1);
    for (var c = 0; c < cells; c++) {
      map.putIfAbsent(d[c], () => map.length);
      out[c] = map[d[c]]!;
    }
    return out;
  }

  /// Whether every ward of [d] is five households in one piece, all 25
  /// assigned.
  static bool sound(List<int?> d) {
    if (d.any((w) => w == null)) return false;
    for (var w = 0; w < wards; w++) {
      final members = [for (var c = 0; c < cells; c++) if (d[c] == w) c];
      if (members.length != wardSize) return false;
      // Connected: flood from the first.
      final seen = {members.first};
      final stack = [members.first];
      while (stack.isNotEmpty) {
        final c = stack.removeLast();
        for (final n in neighbours(c)) {
          if (d[n] == w && seen.add(n)) stack.add(n);
        }
      }
      if (seen.length != wardSize) return false;
    }
    return true;
  }

  /// The wards the Blues win in drawing [d] with the households [blue].
  static int blueWins(List<int> d, List<bool> blue) {
    var wins = 0;
    for (var w = 0; w < wards; w++) {
      var votes = 0;
      for (var c = 0; c < cells; c++) {
        if (d[c] == w && blue[c]) votes++;
      }
      if (votes >= 3) wins++;
    }
    return wins;
  }

  /// The Blues' votes in each ward of a drawing, wards in order.
  static List<int> tally(List<int?> d, List<bool> blue) {
    final out = List.filled(wards, 0);
    for (var c = 0; c < cells; c++) {
      final w = d[c];
      if (w != null && blue[c]) out[w]++;
    }
    return out;
  }

  /// How many drawings give the Blues each count of wards, nought to five.
  static List<int> spread(List<bool> blue) {
    final out = List.filled(wards + 1, 0);
    for (final d in drawings) {
      out[blueWins(d, blue)]++;
    }
    return out;
  }

  /// The most wards a side with [votes] households can win: three
  /// votes to a ward.
  static int mostWards(int votes) => (votes ~/ 3).clamp(0, wards);
}
