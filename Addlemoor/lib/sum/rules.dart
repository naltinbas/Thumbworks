/// The law of the moor.
///
/// Stones numbered one and up stand in a row, each painted one
/// of the moor's paints. A bad sum is three stones sharing a
/// paint with the first two adding to the third, the same stone
/// twice allowed.
///
/// Schur's theorem sets the walls: two paints carry a row to
/// four stones and no further, three carry it to thirteen, and
/// the counts at the walls are exact, 2 paintings and 18. The
/// suite reads every sum, walks every painting, and refuses the
/// bake the moment any two computations part ways.
class Rules {
  Rules(this.stones, this.paints);

  final int stones;
  final int paints;

  /// Every bad sum in a painting: (x, y, z) with x + y = z, all
  /// sharing a paint. Paintings list paint by stone, stone one
  /// at the front.
  static List<(int, int, int)> badSums(List<int> painting) {
    final n = painting.length;
    int paintOf(int stone) => painting[stone - 1];
    return [
      for (var z = 2; z <= n; z++)
        for (var x = 1; x <= z ~/ 2; x++)
          if (paintOf(x) == paintOf(z - x) &&
              paintOf(x) == paintOf(z))
            (x, z - x, z),
    ];
  }

  bool clean(List<int> painting) => badSums(painting).isEmpty;

  /// Every clean painting, walked; calls [visit] with each. The
  /// sweep the checker and the suite share, pruned as it goes.
  void paintings(void Function(List<int>) visit) {
    final painting = <int>[];
    bool okLast() {
      final z = painting.length;
      for (var x = 1; x <= z ~/ 2; x++) {
        if (painting[x - 1] == painting[z - x - 1] &&
            painting[x - 1] == painting[z - 1]) {
          return false;
        }
      }
      return true;
    }

    void walk() {
      if (painting.length == stones) {
        visit(painting);
        return;
      }
      for (var paint = 0; paint < paints; paint++) {
        painting.add(paint);
        if (okLast()) walk();
        painting.removeLast();
      }
    }

    walk();
  }

  /// How many clean paintings the row takes.
  int ways() {
    var count = 0;
    paintings((_) => count++);
    return count;
  }

  /// One clean painting, or null.
  List<int>? painting() {
    List<int>? found;
    paintings((clean) {
      found ??= List.of(clean);
    });
    return found;
  }
}
