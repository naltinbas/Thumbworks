/// The law of the hillside.
///
/// A hill is a triangle of planting spots, side so many, each
/// spot wearing bracken, gorse or heather. The rim is planted
/// before the game begins and never changes: bracken down the
/// left, gorse along the bottom, heather up the right, the three
/// corners one of each. A patch is a smallest triangle of the
/// hill wearing all three plants at once.
///
/// Sperner's lemma is the law: however the inside is planted, the
/// patch count comes out odd. It is checked three ways that share
/// nothing: the census reads the patches off the hill; the rim
/// walk counts bracken-gorse edges round the fixed boundary,
/// exactly one, and the count of patches must match its parity;
/// and the sweep plants the inside every way there is and finds
/// no even count anywhere. The suite refuses the bake the moment
/// any two part ways.
class Rules {
  Rules(this.side);

  final int side;

  /// Every spot of the hill: (row, place), row down from the
  /// peak, place along it.
  List<(int, int)> get spots => [
        for (var row = 0; row <= side; row++)
          for (var place = 0; place <= row; place++) (row, place),
      ];

  /// The smallest triangles of the hill, pointing up and down.
  List<((int, int), (int, int), (int, int))> get patches3 => [
        for (var row = 0; row < side; row++)
          for (var place = 0; place <= row; place++) ...[
            ((row, place), (row + 1, place), (row + 1, place + 1)),
            if (place < row)
              ((row, place), (row, place + 1), (row + 1, place + 1)),
          ],
      ];

  /// The rim's fixed planting: bracken (A) down the left, gorse
  /// (B) along the bottom, heather (C) up the right.
  Map<(int, int), String> get rim {
    final fixed = <(int, int), String>{};
    for (var at = 0; at <= side; at++) {
      fixed[(at, 0)] = at < side ? 'A' : 'B';
      fixed[(side, at)] = at == 0 ? 'B' : 'C';
      fixed[(at, at)] = at == 0 ? 'A' : 'C';
    }
    return fixed;
  }

  /// The spots the player plants.
  List<(int, int)> get inner {
    final fixed = rim;
    return [
      for (final spot in spots)
        if (!fixed.containsKey(spot)) spot,
    ];
  }

  /// The rainbow patches of a planting: every smallest triangle
  /// wearing all three plants.
  List<((int, int), (int, int), (int, int))> rainbow(
      Map<(int, int), String> planted) {
    return [
      for (final patch in patches3)
        if ({
              planted[patch.$1],
              planted[patch.$2],
              planted[patch.$3],
            }.length ==
            3)
          patch,
    ];
  }

  int census(Map<(int, int), String> planted) =>
      rainbow(planted).length;

  /// The rim walk: bracken-gorse edges round the fixed boundary.
  /// Its parity is the law's other voice.
  int rimEdges() {
    final fixed = rim;
    final walk = <((int, int), (int, int))>[
      for (var at = 0; at < side; at++) ((at, 0), (at + 1, 0)),
      for (var at = 0; at < side; at++)
        ((side, at), (side, at + 1)),
      for (var at = side; at > 0; at--)
        ((at, at), (at - 1, at - 1)),
    ];
    return walk
        .where((edge) =>
            {fixed[edge.$1], fixed[edge.$2]}.containsAll(['A', 'B']))
        .length;
  }

  /// Every planting of the inside, walked; calls [visit] with the
  /// full planting. The sweep the checker and the suite share.
  void plantings(void Function(Map<(int, int), String>) visit) {
    final open = inner;
    final planted = Map.of(rim);
    void walk(int at) {
      if (at == open.length) {
        visit(planted);
        return;
      }
      for (final plant in const ['A', 'B', 'C']) {
        planted[open[at]] = plant;
        walk(at + 1);
      }
      planted.remove(open[at]);
    }

    walk(0);
  }

  /// The sweep's spread: how many plantings land each patch
  /// count.
  Map<int, int> spread() {
    final counts = <int, int>{};
    plantings((planted) {
      final patches = census(planted);
      counts[patches] = (counts[patches] ?? 0) + 1;
    });
    return counts;
  }

  /// How many plantings land exactly [asked] patches.
  int waysTo(int asked) => spread()[asked] ?? 0;

  /// One planting landing [asked], or null.
  Map<(int, int), String>? planting(int asked) {
    Map<(int, int), String>? found;
    plantings((planted) {
      if (found == null && census(planted) == asked) {
        found = Map.of(planted);
      }
    });
    return found;
  }

  /// Whether the law holds over the whole sweep: every census
  /// matches the rim walk's parity, and no even count shows.
  bool lawHolds() {
    final parity = rimEdges() % 2;
    var sound = true;
    plantings((planted) {
      final patches = census(planted);
      if (patches % 2 != parity) sound = false;
      if (patches.isEven) sound = false;
    });
    return sound;
  }
}
