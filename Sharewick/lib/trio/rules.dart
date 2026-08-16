/// Six friends, the twenty trios among them, and a family of trios in
/// which every two share a friend. Erdos, Ko and Rado showed in 1961
/// that such a family holds ten trios at most, and here the reason is
/// plain: two trios of six friends miss each other only when one is
/// the other three, so of the ten such pairs a family may take one
/// trio from each and no more.
class Rules {
  static const friends = 6;

  static const names = ['A', 'B', 'C', 'D', 'E', 'F'];

  /// The twenty trios, each a mask of six bits, in the order of their
  /// names: ABC, ABD, ABE, ...
  static final trios = <int>[
    for (var a = 0; a < friends; a++)
      for (var b = a + 1; b < friends; b++)
        for (var c = b + 1; c < friends; c++) (1 << a) | (1 << b) | (1 << c),
  ];

  static int get count => trios.length;

  /// Every family of trios, as a mask of twenty bits.
  static int get families => 1 << count;

  static const all = (1 << friends) - 1;

  /// A trio's name: 'ABC'.
  static String nameOf(int trio) => [for (var f = 0; f < friends; f++) if (trio & (1 << f) != 0) names[f]].join();

  /// The trio of a name.
  static int trioOf(String name) {
    var t = 0;
    for (final ch in name.split('')) {
      t |= 1 << names.indexOf(ch);
    }
    return t;
  }

  static int placeOf(int trio) => trios.indexOf(trio);

  /// The other three: the trio a trio misses entirely.
  static int otherThree(int trio) => all & ~trio;

  /// Whether two trios share a friend.
  static bool share(int t, int u) => t & u != 0;

  static bool picked(int family, int trio) => family & (1 << placeOf(trio)) != 0;

  static int toggled(int family, int trio) => family ^ (1 << placeOf(trio));

  /// The trios of a family, in name order.
  static List<int> triosOf(int family) => [for (var i = 0; i < count; i++) if (family & (1 << i) != 0) trios[i]];

  static int size(int family) => triosOf(family).length;

  /// The pairs of trios in a family that share no friend, the first
  /// voice: every pair looked at.
  static List<(int, int)> apart(int family) {
    final t = triosOf(family);
    return [
      for (var i = 0; i < t.length; i++)
        for (var j = i + 1; j < t.length; j++)
          if (!share(t[i], t[j])) (t[i], t[j]),
    ];
  }

  /// Whether every two trios of a family share a friend.
  static bool sharing(int family) => apart(family).isEmpty;

  /// How many of a family's trios hold each friend.
  static List<int> hands(int family) {
    final h = List<int>.filled(friends, 0);
    for (final t in triosOf(family)) {
      for (var f = 0; f < friends; f++) {
        if (t & (1 << f) != 0) h[f]++;
      }
    }
    return h;
  }

  /// A friend in every trio of the family, or null.
  static int? star(int family) {
    if (family == 0) return null;
    final h = hands(family);
    final n = size(family);
    for (var f = 0; f < friends; f++) {
      if (h[f] == n) return f;
    }
    return null;
  }

  /// The ten pairs of trios that miss each other, each trio with its
  /// other three, the second voice: a family shares throughout exactly
  /// when it takes at most one trio of every pair.
  static List<(int, int)> get missingPairs => [
        for (final t in trios)
          if (t < otherThree(t)) (t, otherThree(t)),
      ];

  /// Whether a family takes at most one trio from every missing pair.
  static bool oneOfEachPair(int family) {
    for (final (t, u) in missingPairs) {
      if (picked(family, t) && picked(family, u)) return false;
    }
    return true;
  }

  /// A family told by its trios: 'ABC, ABD'.
  static String tell(int family) => triosOf(family).map(nameOf).join(', ');

  /// A family from its trios told.
  static int familyOf(String names) {
    var f = 0;
    for (final n in names.split(',')) {
      final t = n.trim();
      if (t.isNotEmpty) f |= 1 << placeOf(trioOf(t));
    }
    return f;
  }
}
