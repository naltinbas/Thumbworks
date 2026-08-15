/// The law of the court.
///
/// A square court of flagstones with one well in it, to be paved
/// with elbows: three flags in an L, a two-by-two block less one
/// corner. Golomb showed in 1954 that a court whose side is a
/// power of two paves round any well at all, quartering the court
/// and laying one elbow at the crossing; the sweep here finds
/// that the four-court does it exactly one way for every one of
/// its sixteen wells. The five-court is another matter: nine of
/// its flags are studs, one to every two-by-two block, and an
/// elbow covers at most one stud, so eight elbows leave a stud
/// bare unless the well is a stud itself. Chu and Johnsonbaugh
/// counted that out in 1986; the sweep counts it here.
class Rules {
  Rules(this.side, this.well);

  final int side;

  /// The well as a cell index, y * side + x.
  final int well;

  int get cells => side * side;

  /// The elbows a court needs: every flag but the well, in
  /// threes.
  int get elbowsNeeded => (cells - 1) ~/ 3;

  int x(int cell) => cell % side;
  int y(int cell) => cell ~/ side;
  int at(int x, int y) => y * side + x;

  /// Whether a cell is a stud: even along and even down, so one
  /// to every two-by-two block.
  bool isStud(int cell) => x(cell).isEven && y(cell).isEven;

  List<int> get studs => [
        for (var cell = 0; cell < cells; cell++)
          if (isStud(cell)) cell,
      ];

  /// Every elbow that fits the court whole, as a sorted list of
  /// three cells, the well kept clear.
  List<List<int>> elbows() {
    final all = <List<int>>[];
    for (var top = 0; top < side - 1; top++) {
      for (var left = 0; left < side - 1; left++) {
        final block = [
          at(left, top),
          at(left + 1, top),
          at(left, top + 1),
          at(left + 1, top + 1),
        ];
        for (final omit in block) {
          final elbow = [
            for (final cell in block)
              if (cell != omit) cell,
          ];
          if (elbow.contains(well)) continue;
          all.add(elbow);
        }
      }
    }
    return all;
  }

  /// Whether three cells make an elbow: a two-by-two block less
  /// one corner, in either order.
  bool isElbow(List<int> three) {
    if (three.length != 3 || three.toSet().length != 3) return false;
    final sorted = List.of(three)..sort();
    final xs = sorted.map(x).toList();
    final ys = sorted.map(y).toList();
    final left = xs.reduce((a, b) => a < b ? a : b);
    final top = ys.reduce((a, b) => a < b ? a : b);
    for (final cell in sorted) {
      if (x(cell) - left > 1 || y(cell) - top > 1) return false;
    }
    // Three distinct cells inside a two-by-two block, and not
    // three in a row, which a block cannot hold.
    return true;
  }

  /// How many studs an elbow covers: never more than one, since
  /// its block holds one.
  int studsUnder(List<int> elbow) =>
      elbow.where(isStud).length;

  /// Whether a paving lands: every flag but the well under an
  /// elbow.
  bool lands(List<List<int>> laid) {
    final covered = <int>{};
    for (final elbow in laid) {
      covered.addAll(elbow);
    }
    return covered.length == cells - 1;
  }

  /// Walks every paving of the court, elbow by elbow from the
  /// first bare flag; calls [visit] with each.
  void pavings(void Function(List<List<int>>) visit) {
    final bare = List.filled(cells, true);
    bare[well] = false;
    final all = elbows();
    final byFirst = <int, List<List<int>>>{};
    for (final elbow in all) {
      byFirst.putIfAbsent(elbow.first, () => []).add(elbow);
    }
    final laid = <List<int>>[];
    void lay() {
      var first = -1;
      for (var cell = 0; cell < cells; cell++) {
        if (bare[cell]) {
          first = cell;
          break;
        }
      }
      if (first < 0) {
        visit(laid);
        return;
      }
      // Every elbow's first cell is its topmost-leftmost, and the
      // first bare flag must be that cell of whatever covers it.
      for (final elbow in byFirst[first] ?? const <List<int>>[]) {
        if (elbow.every((cell) => bare[cell])) {
          for (final cell in elbow) {
            bare[cell] = false;
          }
          laid.add(elbow);
          lay();
          laid.removeLast();
          for (final cell in elbow) {
            bare[cell] = true;
          }
        }
      }
    }

    lay();
  }

  /// How many pavings land, by the sweep.
  int waysBySweep() {
    var ways = 0;
    pavings((_) => ways++);
    return ways;
  }

  /// The first paving the sweep finds, or null.
  List<List<int>>? landing() {
    List<List<int>>? found;
    pavings((laid) {
      found ??= [for (final elbow in laid) List.of(elbow)];
    });
    return found;
  }

  /// Golomb's quartering, for a court whose side is a power of
  /// two: quarter it, lay one elbow at the crossing on the three
  /// quarters without the well, and quarter again. No searching.
  /// Null for any other side.
  List<List<int>>? quartering() {
    if (side < 2 || (side & (side - 1)) != 0) return null;
    final laid = <List<int>>[];
    void quarter(int left, int top, int span, int hole) {
      if (span == 2) {
        laid.add([
          for (var dy = 0; dy < 2; dy++)
            for (var dx = 0; dx < 2; dx++)
              if (at(left + dx, top + dy) != hole) at(left + dx, top + dy),
        ]);
        return;
      }
      final half = span ~/ 2;
      final holeRight = x(hole) >= left + half;
      final holeDown = y(hole) >= top + half;
      // The centre cell of each quarter, nearest the crossing.
      final centres = <(bool, bool, int)>[
        (false, false, at(left + half - 1, top + half - 1)),
        (true, false, at(left + half, top + half - 1)),
        (false, true, at(left + half - 1, top + half)),
        (true, true, at(left + half, top + half)),
      ];
      final elbow = <int>[];
      for (final (right, down, centre) in centres) {
        if (right == holeRight && down == holeDown) continue;
        elbow.add(centre);
      }
      laid.add(elbow..sort());
      for (final (right, down, centre) in centres) {
        final qLeft = right ? left + half : left;
        final qTop = down ? top + half : top;
        final qHole =
            (right == holeRight && down == holeDown) ? hole : centre;
        quarter(qLeft, qTop, half, qHole);
      }
    }

    quarter(0, 0, side, well);
    return laid;
  }
}
