/// The law of the down.
///
/// Posts stand in a ring on the down, and ropes are tied post to
/// post. A triangle is three posts roped to one another, and the
/// tethering rule is never to knot one.
///
/// How many ropes a down can take is Mantel's old law: a quarter
/// of the square of the posts, rounded down, and every tethering
/// that reaches the line splits the posts into two pastures with
/// every rope crossing between them. It is checked three ways
/// that share nothing: the census reads the triangles off the
/// down; the pasture arithmetic bounds the ropes, two pastures of
/// a and b posts holding a times b ropes at most; and the sweep
/// ties every tethering there is and counts. The suite refuses
/// the bake the moment any two part ways.
class Rules {
  Rules(this.posts);

  final int posts;

  /// Every rope a down could carry.
  List<(int, int)> get allRopes => [
        for (var a = 0; a < posts; a++)
          for (var b = a + 1; b < posts; b++) (a, b),
      ];

  /// Mantel's fence line: the most ropes with no triangle.
  int get fenceLine => posts * posts ~/ 4;

  /// Every triangle three ropes knot.
  List<(int, int, int)> triangles(List<(int, int)> ropes) {
    final tied = ropes.toSet();
    bool roped(int a, int b) =>
        tied.contains((a, b)) || tied.contains((b, a));
    return [
      for (var a = 0; a < posts; a++)
        for (var b = a + 1; b < posts; b++)
          for (var c = b + 1; c < posts; c++)
            if (roped(a, b) && roped(a, c) && roped(b, c)) (a, b, c),
    ];
  }

  bool triangleFree(List<(int, int)> ropes) =>
      triangles(ropes).isEmpty;

  /// Whether a tethering splits into two pastures with every rope
  /// crossing between them and every crossing roped: a complete
  /// two-pasture, Mantel's shape of fullness.
  bool twoPasture(List<(int, int)> ropes) {
    final tied = {
      for (final (a, b) in ropes) (a, b),
      for (final (a, b) in ropes) (b, a),
    };
    for (var split = 0; split < (1 << posts); split++) {
      var matches = true;
      for (var a = 0; a < posts && matches; a++) {
        for (var b = a + 1; b < posts && matches; b++) {
          final crosses =
              ((split >> a) & 1) != ((split >> b) & 1);
          if (crosses != tied.contains((a, b))) matches = false;
        }
      }
      if (matches) return true;
    }
    return false;
  }

  /// Every tethering of [count] ropes, walked; calls [visit] with
  /// each. The sweep the checker and the suite share.
  void tetherings(
      int count, void Function(List<(int, int)>) visit) {
    final ropes = allRopes;
    final picked = <(int, int)>[];
    void walk(int from) {
      if (picked.length == count) {
        visit(picked);
        return;
      }
      for (var at = from; at < ropes.length; at++) {
        picked.add(ropes[at]);
        walk(at + 1);
        picked.removeLast();
      }
    }

    walk(0);
  }

  /// How many tetherings of [count] ropes knot no triangle.
  int waysTo(int count) {
    var ways = 0;
    tetherings(count, (ropes) {
      if (triangleFree(ropes)) ways++;
    });
    return ways;
  }

  /// One triangle-free tethering of [count] ropes, or null.
  List<(int, int)>? tethering(int count) {
    List<(int, int)>? found;
    tetherings(count, (ropes) {
      if (found == null && triangleFree(ropes)) {
        found = List.of(ropes);
      }
    });
    return found;
  }

  /// Whether every triangle-free tethering at the fence line is a
  /// complete two-pasture: Mantel's structure, swept.
  bool fullestSplit() {
    var sound = true;
    tetherings(fenceLine, (ropes) {
      if (triangleFree(ropes) && !twoPasture(ropes)) sound = false;
    });
    return sound;
  }

  /// The most ropes two pastures can hold, over every split of
  /// the posts: the arithmetic voice for the fence line.
  int pastureMost() {
    var most = 0;
    for (var oneSide = 0; oneSide <= posts; oneSide++) {
      final held = oneSide * (posts - oneSide);
      if (held > most) most = held;
    }
    return most;
  }
}
