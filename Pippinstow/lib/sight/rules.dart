/// An orchard of ten rows and ten files, a tree at every crossing, and a
/// watcher at the gate, the corner one step outside the first tree of
/// all. A tree is in sight exactly when no other tree stands on the
/// straight line to it, and that is exactly when its file and its row
/// share no factor: Euclid's orchard.
class Rules {
  static const side = 10;

  /// A tree: its file across, 1 to 10, and its row up, 1 to 10.
  static final trees = <(int, int)>[
    for (var b = 1; b <= side; b++)
      for (var a = 1; a <= side; a++) (a, b),
  ];

  static int get count => trees.length;

  static bool inOrchard((int, int) t) => t.$1 >= 1 && t.$1 <= side && t.$2 >= 1 && t.$2 <= side;

  static int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);

  /// In sight by the factor, the first voice: file and row coprime.
  static bool seenByFactor((int, int) t) => gcd(t.$1, t.$2) == 1;

  /// The trees on the straight line from the gate to [t] short of it,
  /// looked for one by one, the second voice: (c, d) with c below the
  /// file or d below the row and a d equal to b c.
  static List<(int, int)> between((int, int) t) => [
        for (final u in trees)
          if ((u.$1 < t.$1 || u.$2 < t.$2) && u.$1 <= t.$1 && u.$2 <= t.$2 && t.$1 * u.$2 == t.$2 * u.$1) u,
      ];

  static bool seenByLine((int, int) t) => between(t).isEmpty;

  /// The tree in front of a hidden tree, nearest the gate on its line, or
  /// null when the tree is in sight.
  static (int, int)? front((int, int) t) {
    final g = gcd(t.$1, t.$2);
    return g == 1 ? null : (t.$1 ~/ g, t.$2 ~/ g);
  }

  /// The trees a tree in sight hides, behind it on its line, farther
  /// from the gate: its multiples in the orchard. A hidden tree hides
  /// nothing of its own, standing in a shadow already.
  static List<(int, int)> hides((int, int) t) => !seenByFactor(t)
      ? const []
      : [
          for (final u in trees)
            if ((u.$1 > t.$1 || u.$2 > t.$2) && u.$1 >= t.$1 && u.$2 >= t.$2 && t.$1 * u.$2 == t.$2 * u.$1) u,
        ];

  static String tell((int, int) t) => '(${t.$1}, ${t.$2})';

  static String tellAll(List<(int, int)> list) {
    if (list.isEmpty) return 'none';
    if (list.length == 1) return tell(list.first);
    return '${list.sublist(0, list.length - 1).map(tell).join(', ')} and ${tell(list.last)}';
  }
}
