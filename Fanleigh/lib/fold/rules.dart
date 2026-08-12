/// The law of the fold.
///
/// Posts stand at the corners of a paddock, rim rails between
/// neighbours, and hurdles are laid post to post across the
/// middle. A full fencing lays posts-less-three hurdles, none
/// crossing, and folds the paddock into posts-less-two
/// three-post pens. Each post's crown is the number of pens it
/// corners, and a post cornering exactly one pen is an ear.
///
/// The counts are Catalan's and the ears are the old two-ears
/// theorem: every full fencing keeps at least two. The suite
/// lays every fencing, reads every crown, and refuses the bake
/// the moment any two computations part ways.
class Rules {
  Rules(this.posts);

  final int posts;

  /// Every hurdle the paddock could take: non-rim post pairs.
  List<(int, int)> get allHurdles => [
        for (var a = 0; a < posts; a++)
          for (var b = a + 2; b < posts; b++)
            if (!(a == 0 && b == posts - 1)) (a, b),
      ];

  /// Whether two hurdles cross inside the paddock.
  static bool cross((int, int) one, (int, int) two) {
    final (a, b) = one.$1 < one.$2 ? one : (one.$2, one.$1);
    final (c, d) = two.$1 < two.$2 ? two : (two.$2, two.$1);
    return (a < c && c < b && b < d) || (c < a && a < d && d < b);
  }

  /// The crossing pairs among laid hurdles.
  static List<((int, int), (int, int))> crossings(
      List<(int, int)> hurdles) {
    final found = <((int, int), (int, int))>[];
    for (var x = 0; x < hurdles.length; x++) {
      for (var y = x + 1; y < hurdles.length; y++) {
        if (cross(hurdles[x], hurdles[y])) {
          found.add((hurdles[x], hurdles[y]));
        }
      }
    }
    return found;
  }

  /// Whether the fencing is full: enough hurdles, none crossing.
  bool fenced(List<(int, int)> hurdles) =>
      hurdles.length == posts - 3 && crossings(hurdles).isEmpty;

  /// The pens of a full fencing: every post triple whose three
  /// sides are all rails or hurdles.
  List<(int, int, int)> pens(List<(int, int)> hurdles) {
    final edges = <(int, int)>{
      for (var at = 0; at < posts; at++)
        at < (at + 1) % posts
            ? (at, (at + 1) % posts)
            : ((at + 1) % posts, at),
      for (final (a, b) in hurdles) a < b ? (a, b) : (b, a),
    };
    bool joined(int a, int b) =>
        edges.contains(a < b ? (a, b) : (b, a));
    return [
      for (var a = 0; a < posts; a++)
        for (var b = a + 1; b < posts; b++)
          for (var c = b + 1; c < posts; c++)
            if (joined(a, b) && joined(a, c) && joined(b, c))
              (a, b, c),
    ];
  }

  /// Each post's crown: the pens it corners.
  List<int> crown(List<(int, int)> hurdles) {
    final counted = List.filled(posts, 0);
    for (final (a, b, c) in pens(hurdles)) {
      counted[a]++;
      counted[b]++;
      counted[c]++;
    }
    return counted;
  }

  /// The ears: posts cornering exactly one pen.
  List<int> ears(List<(int, int)> hurdles) {
    final crowned = crown(hurdles);
    return [
      for (var at = 0; at < posts; at++)
        if (crowned[at] == 1) at,
    ];
  }

  /// Every full fencing, walked; calls [visit] with each. The
  /// sweep the checker and the suite share.
  void fencings(void Function(List<(int, int)>) visit) {
    final hurdles = allHurdles;
    final picked = <(int, int)>[];
    void walk(int from) {
      if (picked.length == posts - 3) {
        if (crossings(picked).isEmpty) visit(picked);
        return;
      }
      for (var at = from; at < hurdles.length; at++) {
        picked.add(hurdles[at]);
        walk(at + 1);
        picked.removeLast();
      }
    }

    walk(0);
  }

  /// How many full fencings there are: Catalan's count, laid out.
  int foldings() {
    var count = 0;
    fencings((_) => count++);
    return count;
  }

  /// How many full fencings satisfy [asking] on their crown.
  int waysTo(bool Function(List<int> crown) asking) {
    var count = 0;
    fencings((hurdles) {
      if (asking(crown(hurdles))) count++;
    });
    return count;
  }

  /// One full fencing satisfying [asking], or null.
  List<(int, int)>? fencing(bool Function(List<int> crown) asking) {
    List<(int, int)>? found;
    fencings((hurdles) {
      if (found == null && asking(crown(hurdles))) {
        found = List.of(hurdles);
      }
    });
    return found;
  }

  /// Whether the laws hold over the whole sweep: pens number
  /// posts less two, crowns sum to three times that, every
  /// fencing keeps at least two ears, and no two fencings share
  /// a crown.
  bool lawHolds() {
    var sound = true;
    final seen = <String>{};
    fencings((hurdles) {
      final folded = pens(hurdles);
      if (folded.length != posts - 2) sound = false;
      final crowned = crown(hurdles);
      if (crowned.fold(0, (a, b) => a + b) != 3 * (posts - 2)) {
        sound = false;
      }
      if (ears(hurdles).length < 2) sound = false;
      if (!seen.add(crowned.join(','))) sound = false;
    });
    return sound;
  }
}
