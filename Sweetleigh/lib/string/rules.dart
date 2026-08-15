/// The law of the string.
///
/// Sweets on a string, so many of each kind, an even count of
/// every kind, and two children to share them. Cut the string in
/// a few places and hand the pieces out in turn, first child,
/// second child, first child again; the share is fair when each
/// child holds exactly half of every kind. The necklace theorem
/// says as many cuts as there are kinds always suffice: two kinds,
/// two cuts, and the proof is a window you can slide with your
/// thumb. Some strings need every one of those cuts, and the
/// string of reds-then-blues is one of them: one cut never shares
/// it, since any first piece with two blues in it holds all four
/// reds.
class Rules {
  Rules(this.sweets);

  /// The string, one letter a sweet: R, B, G.
  final String sweets;

  int get length => sweets.length;

  /// The kinds on the string, in order of first appearance.
  List<String> get kinds {
    final seen = <String>[];
    for (final sweet in sweets.split('')) {
      if (!seen.contains(sweet)) seen.add(sweet);
    }
    return seen;
  }

  /// How many of a kind.
  int countOf(String kind) => sweets.split('').where((s) => s == kind).length;

  /// The pieces a set of cuts makes, in order along the string.
  /// A cut at gap g falls between sweet g - 1 and sweet g.
  List<String> pieces(List<int> cuts) {
    final sorted = List<int>.of(cuts)..sort();
    final out = <String>[];
    var last = 0;
    for (final cut in [...sorted, length]) {
      out.add(sweets.substring(last, cut));
      last = cut;
    }
    return out;
  }

  /// What each child holds: kind to count, for the first child
  /// and the second, the pieces handed out in turn.
  (Map<String, int>, Map<String, int>) shares(List<int> cuts) {
    final first = <String, int>{};
    final second = <String, int>{};
    final all = pieces(cuts);
    for (var i = 0; i < all.length; i++) {
      final hand = i.isEven ? first : second;
      for (final sweet in all[i].split('')) {
        hand[sweet] = (hand[sweet] ?? 0) + 1;
      }
    }
    return (first, second);
  }

  /// Whether the cuts share the string fairly: half of every kind
  /// to each child.
  bool fair(List<int> cuts) {
    final (first, second) = shares(cuts);
    for (final kind in kinds) {
      if ((first[kind] ?? 0) != (second[kind] ?? 0)) return false;
    }
    return true;
  }

  /// Every set of at most [most] cuts, walked; calls [visit].
  void cutSets(int most, void Function(List<int>) visit) {
    final cuts = <int>[];
    void choose(int from) {
      visit(cuts);
      if (cuts.length == most) return;
      for (var gap = from; gap < length; gap++) {
        cuts.add(gap);
        choose(gap + 1);
        cuts.removeLast();
      }
    }

    choose(1);
  }

  /// How many sets of at most [most] cuts share fairly.
  int waysBySweep(int most) {
    var ways = 0;
    cutSets(most, (cuts) {
      if (fair(cuts)) ways++;
    });
    return ways;
  }

  /// The first fair set of at most [most] cuts the sweep finds,
  /// fewest cuts first, or null.
  List<int>? landing(int most) {
    for (var k = 0; k <= most; k++) {
      List<int>? found;
      cutSets(k, (cuts) {
        if (found == null && cuts.length == k && fair(cuts)) {
          found = List.of(cuts);
        }
      });
      if (found != null) return found;
    }
    return null;
  }

  /// The fewest cuts that share this string, by the sweep.
  int fewest() {
    for (var k = 0; k <= length; k++) {
      if (waysBySweep(k) > 0) return k;
    }
    return length;
  }

  /// The window: for two kinds, slide a piece half the string
  /// long from one end to the other and count the first kind in
  /// it; the count moves by at most one per step and ends at
  /// what it did not start with, so somewhere it is exactly half.
  /// Returns the two cuts round that window, built and not
  /// searched, or null when the string is not two kinds with even
  /// counts.
  List<int>? window() {
    final two = kinds;
    if (two.length != 2 || length.isOdd) return null;
    final kind = two.first;
    final half = countOf(kind) ~/ 2;
    if (countOf(kind).isOdd) return null;
    final span = length ~/ 2;
    for (var start = 0; start + span <= length; start++) {
      final inWindow =
          sweets.substring(start, start + span).split('').where((s) => s == kind).length;
      if (inWindow == half) {
        return [
          if (start > 0) start,
          if (start + span < length) start + span,
        ];
      }
    }
    return null;
  }

  /// Every string with these counts of each kind, walked; calls
  /// [visit] with each.
  static void strings(Map<String, int> counts, void Function(String) visit) {
    final kinds = counts.keys.toList();
    final left = Map<String, int>.of(counts);
    final total = counts.values.fold(0, (a, b) => a + b);
    final so = <String>[];
    void build() {
      if (so.length == total) {
        visit(so.join());
        return;
      }
      for (final kind in kinds) {
        if (left[kind]! == 0) continue;
        left[kind] = left[kind]! - 1;
        so.add(kind);
        build();
        so.removeLast();
        left[kind] = left[kind]! + 1;
      }
    }

    build();
  }
}
