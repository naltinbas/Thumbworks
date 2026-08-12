/// The law of the stack.
///
/// A box is painted on six faces, held as three sleeves: front
/// and back, left and right, top and bottom. Boxes stand in a
/// stack, and the stack is settled when each of its four walls
/// shows every box a different colour.
///
/// Whether a set of boxes can settle is known more ways than one:
/// the wall check reads the standing stack; the sweep turns every
/// box every way and counts the settlings; the factoring pairs
/// the sleeves into two disjoint picks with every colour touched
/// exactly twice, the old pencil-and-paper road; and on the
/// hopeless set a count of faces settles it before a box is
/// turned. The suite refuses the bake the moment any two part
/// ways.
class Rules {
  /// The walls a box can show, each as (front, right, back, left),
  /// every distinct turning once.
  static List<(String, String, String, String)> turnings(
      List<(String, String)> sleeves) {
    final walls = <(String, String, String, String)>{};
    final axes = [
      (sleeves[1], sleeves[2]),
      (sleeves[0], sleeves[2]),
      (sleeves[0], sleeves[1]),
    ];
    for (final (p, q) in axes) {
      for (final pf in [p, (p.$2, p.$1)]) {
        for (final qf in [q, (q.$2, q.$1)]) {
          final ring = [pf.$1, qf.$1, pf.$2, qf.$2];
          for (var spin = 0; spin < 4; spin++) {
            walls.add((
              ring[spin % 4],
              ring[(spin + 1) % 4],
              ring[(spin + 2) % 4],
              ring[(spin + 3) % 4],
            ));
          }
        }
      }
    }
    return walls.toList()..sort((a, b) => '$a'.compareTo('$b'));
  }

  /// Whether the standing walls settle: each of the four shows no
  /// colour twice.
  static bool settled(List<(String, String, String, String)> stack) {
    for (var wall = 0; wall < 4; wall++) {
      final seen = <String>{};
      for (final box in stack) {
        final face = [box.$1, box.$2, box.$3, box.$4][wall];
        if (!seen.add(face)) return false;
      }
    }
    return true;
  }

  /// The sweep: every turning of every box, counting the
  /// settlings.
  static int settlings(List<List<(String, String)>> boxes) {
    final options = [for (final box in boxes) turnings(box)];
    var count = 0;
    void walk(int at, List<(String, String, String, String)> stood) {
      if (at == boxes.length) {
        if (settled(stood)) count++;
        return;
      }
      for (final turning in options[at]) {
        stood.add(turning);
        // Prune: the walls so far must already show no doubles.
        if (settled(stood)) walk(at + 1, stood);
        stood.removeLast();
      }
    }

    walk(0, []);
    return count;
  }

  /// One settling, or null: the sweep stopped at its first find.
  static List<(String, String, String, String)>? settling(
      List<List<(String, String)>> boxes) {
    final options = [for (final box in boxes) turnings(box)];
    List<(String, String, String, String)>? found;
    bool walk(int at, List<(String, String, String, String)> stood) {
      if (at == boxes.length) {
        if (settled(stood)) {
          found = List.of(stood);
          return true;
        }
        return false;
      }
      for (final turning in options[at]) {
        stood.add(turning);
        if (settled(stood) && walk(at + 1, stood)) return true;
        stood.removeLast();
      }
      return false;
    }

    walk(0, []);
    return found;
  }

  /// The colours a set of boxes wears.
  static Set<String> colours(List<List<(String, String)>> boxes) => {
        for (final box in boxes)
          for (final sleeve in box) ...[sleeve.$1, sleeve.$2],
      };

  /// The factoring voice, for four boxes of four colours: a pick
  /// takes one sleeve per box; a fair pick touches every colour
  /// exactly twice; the set settles exactly when two fair picks
  /// share no sleeve. The old pencil-and-paper road, nowhere near
  /// the sweep.
  static bool factors(List<List<(String, String)>> boxes) {
    final fair = fairPicks(boxes);
    for (final one in fair) {
      for (final two in fair) {
        var disjoint = true;
        for (var box = 0; box < boxes.length; box++) {
          if (one[box] == two[box]) {
            disjoint = false;
            break;
          }
        }
        if (disjoint) return true;
      }
    }
    return false;
  }

  static List<List<int>> fairPicks(
      List<List<(String, String)>> boxes) {
    final all = colours(boxes);
    final fair = <List<int>>[];
    void walk(int at, List<int> picked, Map<String, int> touched) {
      if (at == boxes.length) {
        if (touched.length == all.length &&
            touched.values.every((deg) => deg == 2)) {
          fair.add(List.of(picked));
        }
        return;
      }
      for (var sleeve = 0; sleeve < 3; sleeve++) {
        final (a, b) = boxes[at][sleeve];
        touched[a] = (touched[a] ?? 0) + 1;
        touched[b] = (touched[b] ?? 0) + 1;
        if (touched[a]! <= 2 && touched[b]! <= 2) {
          picked.add(sleeve);
          walk(at + 1, picked, touched);
          picked.removeLast();
        }
        touched[a] = touched[a]! - 1;
        touched[b] = touched[b]! - 1;
        if (touched[a] == 0) touched.remove(a);
        if (touched[b] == 0) touched.remove(b);
      }
    }

    walk(0, [], {});
    return fair;
  }

  /// How many faces of the boxes wear a colour.
  static int facesWearing(
          List<List<(String, String)>> boxes, String colour) =>
      [
        for (final box in boxes)
          for (final sleeve in box) ...[sleeve.$1, sleeve.$2],
      ].where((face) => face == colour).length;

  /// The most faces of one colour a standing stack can carry:
  /// one on each wall, and the tops and bottoms hidden.
  static int roomFor(int boxes) => 4 + 2 * boxes;

  /// The fair picks of a set: one sleeve per box, every colour
  /// touched exactly twice.
  static int fairPickCount(List<List<(String, String)>> boxes) =>
      fairPicks(boxes).length;

  /// The disjoint unordered pairs among the fair picks: the
  /// pencil factorings.
  static int factorings(List<List<(String, String)>> boxes) {
    final fair = fairPicks(boxes);
    var pairs = 0;
    for (var i = 0; i < fair.length; i++) {
      for (var j = i + 1; j < fair.length; j++) {
        var disjoint = true;
        for (var box = 0; box < boxes.length; box++) {
          if (fair[i][box] == fair[j][box]) {
            disjoint = false;
            break;
          }
        }
        if (disjoint) pairs++;
      }
    }
    return pairs;
  }

  /// Every settling, listed; the sweep behind the class count.
  static List<List<(String, String, String, String)>> settlingsAll(
      List<List<(String, String)>> boxes) {
    final options = [for (final box in boxes) turnings(box)];
    final found = <List<(String, String, String, String)>>[];
    void walk(int at, List<(String, String, String, String)> stood) {
      if (at == boxes.length) {
        if (settled(stood)) found.add(List.of(stood));
        return;
      }
      for (final turning in options[at]) {
        stood.add(turning);
        if (settled(stood)) walk(at + 1, stood);
        stood.removeLast();
      }
    }

    walk(0, []);
    return found;
  }

  /// How many settlings remain once whole-stack turns and
  /// mirrorings are worn away.
  static int settlingClasses(List<List<(String, String)>> boxes) {
    final all = settlingsAll(boxes);
    String keyOf(List<(String, String, String, String)> s) =>
        s.map((b) => '${b.$1}${b.$2}${b.$3}${b.$4}').join('|');
    (String, String, String, String) spin(
            (String, String, String, String) b, int k) =>
        ([b.$1, b.$2, b.$3, b.$4][k % 4],
            [b.$1, b.$2, b.$3, b.$4][(k + 1) % 4],
            [b.$1, b.$2, b.$3, b.$4][(k + 2) % 4],
            [b.$1, b.$2, b.$3, b.$4][(k + 3) % 4]);
    final seen = <String>{};
    var classes = 0;
    for (final s in all) {
      if (seen.contains(keyOf(s))) continue;
      classes++;
      for (var k = 0; k < 4; k++) {
        for (final mirrored in [false, true]) {
          final image = [
            for (final b in s)
              mirrored
                  ? ((String, String, String, String) turned) {
                      return (turned.$1, turned.$4, turned.$3,
                          turned.$2);
                    }(spin(b, k))
                  : spin(b, k),
          ];
          seen.add(keyOf(image));
        }
      }
    }
    return classes;
  }
}
