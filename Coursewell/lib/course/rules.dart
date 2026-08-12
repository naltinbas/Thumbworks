/// The law of the yard.
///
/// A yard of cells is bricked with dominoes, each covering two
/// neighbouring cells. A seam is a straight line through the
/// whole yard, wall to wall, that no brick crosses: where a
/// seam runs, the work can shear.
///
/// The five-by-six yard lays sound, seamless, exactly six ways,
/// the smallest yard that can. The six-by-six never does, by a
/// counting told on fingers: it has ten inner lines, a sound
/// laying must cross each with at least two bricks, no brick
/// crosses two lines, and eighteen bricks cannot pay twenty.
/// The suite lays every tiling, reads every seam, and refuses
/// the bake the moment any two computations part ways.
class Rules {
  Rules(this.width, this.height);

  final int width;
  final int height;

  int get cells => width * height;

  /// The inner lines of the yard, both ways.
  int get innerLines => (width - 1) + (height - 1);
  int get bricks => cells ~/ 2;

  /// The seams of a laying: inner lines, upright and level, that
  /// no brick crosses. Bricks pair cell indexes, x + y * width.
  List<(bool, int)> seams(List<(int, int)> laying) {
    final crossedUpright = <int>{};
    final crossedLevel = <int>{};
    for (final (a, b) in laying) {
      final ax = a % width, ay = a ~/ width;
      final bx = b % width, by = b ~/ width;
      if (ax != bx) {
        crossedUpright.add(ax > bx ? ax : bx);
      } else {
        crossedLevel.add(ay > by ? ay : by);
      }
    }
    return [
      for (var line = 1; line < width; line++)
        if (!crossedUpright.contains(line)) (true, line),
      for (var line = 1; line < height; line++)
        if (!crossedLevel.contains(line)) (false, line),
    ];
  }

  /// Whether a laying covers the yard whole.
  bool bricked(List<(int, int)> laying) {
    final covered = <int>{};
    for (final (a, b) in laying) {
      if (!covered.add(a) || !covered.add(b)) return false;
    }
    return covered.length == cells;
  }

  /// Every full laying, walked; calls [visit] with each. The
  /// sweep the checker and the suite share.
  void layings(void Function(List<(int, int)>) visit) {
    final covered = List.filled(cells, false);
    final laid = <(int, int)>[];
    void walk() {
      var first = -1;
      for (var cell = 0; cell < cells; cell++) {
        if (!covered[cell]) {
          first = cell;
          break;
        }
      }
      if (first < 0) {
        visit(laid);
        return;
      }
      final x = first % width;
      // Rightward.
      if (x + 1 < width && !covered[first + 1]) {
        covered[first] = true;
        covered[first + 1] = true;
        laid.add((first, first + 1));
        walk();
        laid.removeLast();
        covered[first] = false;
        covered[first + 1] = false;
      }
      // Downward.
      if (first + width < cells && !covered[first + width]) {
        covered[first] = true;
        covered[first + width] = true;
        laid.add((first, first + width));
        walk();
        laid.removeLast();
        covered[first] = false;
        covered[first + width] = false;
      }
    }

    walk();
  }

  /// How many full layings keep exactly [asked] seams; any count
  /// when [asked] is null.
  int waysTo(int? asked) {
    var count = 0;
    layings((laying) {
      if (asked == null || seams(laying).length == asked) {
        count++;
      }
    });
    return count;
  }

  /// One full laying keeping exactly [asked] seams, or null.
  List<(int, int)>? laying(int? asked) {
    List<(int, int)>? found;
    layings((laid) {
      if (found == null &&
          (asked == null || seams(laid).length == asked)) {
        found = List.of(laid);
      }
    });
    return found;
  }
}
