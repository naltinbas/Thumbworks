/// A village of places joined by streets, and the game of making every
/// street one-way. An orientation is one arrow for each street: false
/// leaves it pointing the way the village lists it, true turns it
/// about.
///
/// Robbins' theorem, from Herbert Robbins in 1939, says a connected
/// village can be made one-way throughout, every place still reachable
/// from every other, exactly when no street is a bridge: a street whose
/// closing would cut the village in two. Point a bridge either way and
/// the far side can be reached but never left.
library;

/// A street, told by the two places it joins.
typedef Street = (int, int);

/// One village: where its places stand and which pairs a street joins.
class Village {
  const Village({
    required this.name,
    required this.places,
    required this.streets,
    required this.opening,
  });

  final String name;

  /// Where each place stands, on a grid 0 to 8 across and down.
  final List<(int, int)> places;

  final List<Street> streets;

  /// The arrows the ask opens on, which is never one that lands it.
  final List<bool> opening;

  int get placeCount => places.length;

  int get streetCount => streets.length;

  /// Every way the streets can be pointed.
  int get orientations => 1 << streets.length;
}

class Rules {
  /// The five villages, in the order the asks take them.
  static const green = Village(
    name: 'the green',
    places: [(0, 0), (4, 0), (8, 0), (0, 4), (4, 4), (8, 4), (0, 8), (4, 8), (8, 8)],
    streets: [
      (0, 1), (1, 2), (3, 4), (4, 5), (6, 7), (7, 8),
      (0, 3), (3, 6), (1, 4), (4, 7), (2, 5), (5, 8),
    ],
    opening: [false, false, false, true, true, true, false, false, false, true, true, true],
  );

  static const square = Village(
    name: 'the square',
    places: [(1, 1), (7, 1), (7, 7), (1, 7)],
    streets: [(0, 1), (1, 2), (2, 3), (3, 0)],
    opening: [false, false, true, true],
  );

  static const house = Village(
    name: 'the house',
    places: [(0, 8), (8, 8), (8, 3), (0, 3), (4, 0)],
    streets: [(0, 1), (1, 2), (2, 3), (3, 0), (3, 4), (4, 2)],
    opening: [false, false, false, true, false, true],
  );

  static const rings = Village(
    name: 'the two rings',
    places: [(0, 0), (8, 0), (8, 8), (0, 8), (3, 3), (5, 3), (5, 5), (3, 5)],
    streets: [
      (0, 1), (1, 2), (2, 3), (3, 0),
      (4, 5), (5, 6), (6, 7), (7, 4),
      (0, 4), (1, 5), (2, 6), (3, 7),
    ],
    opening: [false, false, true, true, false, true, true, false, false, false, true, true],
  );

  static const toll = Village(
    name: 'the toll lane',
    places: [(0, 0), (4, 0), (2, 3), (2, 5), (0, 8), (4, 8)],
    streets: [(0, 1), (1, 2), (2, 0), (3, 4), (4, 5), (5, 3), (2, 3)],
    opening: [false, false, false, false, false, false, false],
  );

  static const villages = [green, square, house, rings, toll];

  /// Where a street runs under an orientation: the place it leaves and
  /// the place it reaches.
  static Street pointed(Village village, List<bool> ways, int street) {
    final (a, b) = village.streets[street];
    return ways[street] ? (b, a) : (a, b);
  }

  static bool valid(Village village, List<bool> ways) =>
      ways.length == village.streetCount;

  /// The places reachable from [from], arrows obeyed.
  static Set<int> reaches(Village village, List<bool> ways, int from) {
    final out = List.generate(village.placeCount, (_) => <int>[]);
    for (var s = 0; s < village.streetCount; s++) {
      final (a, b) = pointed(village, ways, s);
      out[a].add(b);
    }
    final seen = <int>{from};
    final queue = <int>[from];
    for (var head = 0; head < queue.length; head++) {
      for (final there in out[queue[head]]) {
        if (seen.add(there)) queue.add(there);
      }
    }
    return seen;
  }

  /// How many ordered pairs of places can be got between, of the
  /// [placeCount] * ([placeCount] - 1) there are.
  static int pairs(Village village, List<bool> ways) {
    var got = 0;
    for (var from = 0; from < village.placeCount; from++) {
      got += reaches(village, ways, from).length - 1;
    }
    return got;
  }

  /// Every ordered pair got between: the village is one-way throughout.
  static bool strong(Village village, List<bool> ways) =>
      pairs(village, ways) == village.placeCount * (village.placeCount - 1);

  /// Every place reachable from every other with the streets left two
  /// way, which every village here is.
  static bool joined(Village village, [List<Street>? streets]) {
    final all = streets ?? village.streets;
    final near = List.generate(village.placeCount, (_) => <int>[]);
    for (final (a, b) in all) {
      near[a].add(b);
      near[b].add(a);
    }
    final seen = <int>{0};
    final queue = <int>[0];
    for (var head = 0; head < queue.length; head++) {
      for (final there in near[queue[head]]) {
        if (seen.add(there)) queue.add(there);
      }
    }
    return seen.length == village.placeCount;
  }

  /// The streets whose closing would cut the village in two, found by
  /// closing each in turn.
  static List<int> bridges(Village village) {
    final out = <int>[];
    for (var s = 0; s < village.streetCount; s++) {
      final rest = [
        for (var k = 0; k < village.streetCount; k++)
          if (k != s) village.streets[k],
      ];
      if (!joined(village, rest)) out.add(s);
    }
    return out;
  }

  /// The same streets found the other way about, by the depth-first
  /// walk that keeps the earliest place each branch can climb back to.
  static List<int> bridgesByWalk(Village village) {
    final near = List.generate(village.placeCount, (_) => <(int, int)>[]);
    for (var s = 0; s < village.streetCount; s++) {
      final (a, b) = village.streets[s];
      near[a].add((b, s));
      near[b].add((a, s));
    }
    final when = List.filled(village.placeCount, -1);
    final climb = List.filled(village.placeCount, -1);
    final out = <int>[];
    var clock = 0;

    void walk(int here, int by) {
      when[here] = climb[here] = clock++;
      for (final (there, street) in near[here]) {
        if (street == by) continue;
        if (when[there] < 0) {
          walk(there, street);
          if (climb[there] < climb[here]) climb[here] = climb[there];
          if (climb[there] > when[here]) out.add(street);
        } else if (when[there] < climb[here]) {
          climb[here] = when[there];
        }
      }
    }

    for (var place = 0; place < village.placeCount; place++) {
      if (when[place] < 0) walk(place, -1);
    }
    out.sort();
    return out;
  }

  /// Every orientation of [village], counted where [likes] holds.
  static int sweep(Village village, bool Function(List<bool>) likes) {
    var got = 0;
    for (var mask = 0; mask < village.orientations; mask++) {
      if (likes(waysOf(village, mask))) got++;
    }
    return got;
  }

  /// The orientation numbered [mask], one bit to a street.
  static List<bool> waysOf(Village village, int mask) =>
      [for (var s = 0; s < village.streetCount; s++) (mask >> s) & 1 == 1];

  static final Map<String, int> _strongCounts = {};

  /// How many orientations leave the village one-way throughout: the
  /// first voice, which tries every one of them.
  static int strongCount(Village village) => _strongCounts.putIfAbsent(
      village.name, () => sweep(village, (ways) => strong(village, ways)));

  static final Map<String, int> _bests = {};

  /// The most ordered pairs any orientation of the village gets
  /// between.
  static int best(Village village) => _bests.putIfAbsent(village.name, () {
        var most = 0;
        for (var mask = 0; mask < village.orientations; mask++) {
          final got = pairs(village, waysOf(village, mask));
          if (got > most) most = got;
        }
        return most;
      });

  static final Map<String, List<bool>?> _aims = {};

  /// The first orientation of the sweep that leaves the village one-way
  /// throughout, or null when none does.
  static List<bool>? aim(Village village) => _aims.putIfAbsent(village.name, () {
        for (var mask = 0; mask < village.orientations; mask++) {
          final ways = waysOf(village, mask);
          if (strong(village, ways)) return ways;
        }
        return null;
      });

  /// Tutte's polynomial of the village's streets at ([x], [y]), worked
  /// out by deleting and contracting one street at a time with the
  /// values already in, so the polynomial itself is never formed. At
  /// (0, 2) it counts the orientations that leave every street on a
  /// round trip, which for a joined village are exactly the
  /// one-way-throughout ones: the second voice, which never tries an
  /// orientation at all.
  static int tutte(List<Street> streets, int x, int y) {
    final loops = streets.where((s) => s.$1 == s.$2).length;
    if (loops > 0) {
      final rest = [for (final s in streets) if (s.$1 != s.$2) s];
      var factor = 1;
      for (var k = 0; k < loops; k++) {
        factor *= y;
      }
      return factor * tutte(rest, x, y);
    }
    if (streets.isEmpty) return 1;
    final street = streets.first;
    final rest = streets.sublist(1);
    if (_parts(rest, streets) > _parts(streets, streets)) {
      return x * tutte(rest, x, y);
    }
    final (a, b) = street;
    final shut = [
      for (final (u, v) in rest) (u == b ? a : u, v == b ? a : v),
    ];
    return tutte(rest, x, y) + tutte(shut, x, y);
  }

  /// How many pieces [streets] falls into, counting only the places
  /// [over] mentions.
  static int _parts(List<Street> streets, List<Street> over) {
    final places = <int>{for (final (a, b) in over) ...[a, b]};
    final owner = <int, int>{for (final p in places) p: p};
    int find(int p) {
      var at = p;
      while (owner[at] != at) {
        owner[at] = owner[owner[at]!]!;
        at = owner[at]!;
      }
      return at;
    }

    for (final (a, b) in streets) {
      final ra = find(a), rb = find(b);
      if (ra != rb) owner[ra] = rb;
    }
    return {for (final p in places) find(p)}.length;
  }

  /// The count of one-way-throughout orientations by the polynomial,
  /// good for a joined village, which every village here is.
  static int strongByTutte(Village village) => tutte(village.streets, 0, 2);

  static final Map<String, List<List<bool>>> _strongs = {};

  /// Every orientation that leaves the village one-way throughout.
  static List<List<bool>> strongWays(Village village) =>
      _strongs.putIfAbsent(village.name, () => [
            for (var mask = 0; mask < village.orientations; mask++)
              if (strong(village, waysOf(village, mask))) waysOf(village, mask),
          ]);

  /// How many streets [a] and [b] point different ways.
  static int apart(List<bool> a, List<bool> b) {
    var count = 0;
    for (var k = 0; k < a.length; k++) {
      if (a[k] != b[k]) count++;
    }
    return count;
  }

  /// The one-way-throughout orientation nearest to [ways], and how many
  /// turns away it is; null when the village has none.
  static (List<bool>, int)? nearest(Village village, List<bool> ways) {
    List<bool>? best;
    var least = -1;
    for (final other in strongWays(village)) {
      final far = apart(ways, other);
      if (least < 0 || far < least) {
        least = far;
        best = other;
      }
    }
    return best == null ? null : (best, least);
  }

  /// What a place is called: A for the first, B for the second.
  static String tellPlace(int place) =>
      String.fromCharCode('A'.codeUnitAt(0) + place);

  /// Which way a street runs, in words: 'A to B'.
  static String tellStreet(Village village, List<bool> ways, int street) {
    final (from, to) = pointed(village, ways, street);
    return '${tellPlace(from)} to ${tellPlace(to)}';
  }
}
