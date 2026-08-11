/// Works out the fewest piles, three unrelated ways, and finds the thread.
///
/// The first way is the theorem: the fewest piles is the length of the
/// longest run of bales that arrive in rising weight. Rising bales can never
/// share a pile, because a pile's top only gets lighter as the morning goes
/// on, so the run is a floor; and setting each bale on the lightest top that
/// can take it never ends above the run, so the floor is the answer. That
/// equality is Dilworth's theorem with the piles as the parts: each pile
/// reads top to bottom as a falling run, so a finished yard is a partition
/// of the morning into falling runs, and the fewest parts equals the longest
/// rising run.
///
/// The second way is the greedy itself, simulated. The third is brute force
/// over every legal way to play the morning, remembering nothing but the
/// pile tops, which is all the future can see. The tests hold all three
/// against each other on every shipped deal and on thousands made up at
/// random, so the theorem is checked here rather than trusted.
class Runs {
  const Runs._();

  /// The longest run of bales arriving in rising weight, as places in the
  /// arrival order. Ties broken toward the earliest thread, not that it
  /// matters: any longest thread is as good a floor as any other.
  static List<int> thread(List<int> tods) {
    final many = tods.length;
    if (many == 0) return const [];

    // longest[i]: the longest rising run ending at bale i; from[i]: the bale
    // before it on one such run.
    final longest = List<int>.filled(many, 1);
    final from = List<int>.filled(many, -1);
    for (var at = 1; at < many; at++) {
      for (var earlier = 0; earlier < at; earlier++) {
        if (tods[earlier] < tods[at] && longest[earlier] + 1 > longest[at]) {
          longest[at] = longest[earlier] + 1;
          from[at] = earlier;
        }
      }
    }

    var end = 0;
    for (var at = 1; at < many; at++) {
      if (longest[at] > longest[end]) end = at;
    }

    final out = <int>[];
    for (var at = end; at != -1; at = from[at]) {
      out.add(at);
    }
    return out.reversed.toList();
  }

  /// The longest run of bales arriving in falling weight. Only the length is
  /// wanted, and only by the boundary tests.
  static int falling(List<int> tods) =>
      thread([for (final tod in tods) -tod]).length;

  /// How many piles the morning ends in when every bale is set on the
  /// lightest top that can take it, starting from pile tops already standing.
  static int byBestFit(List<int> tops, List<int> coming) {
    final standing = [...tops];
    for (final tod in coming) {
      var snuggest = -1;
      for (var pile = 0; pile < standing.length; pile++) {
        if (standing[pile] <= tod) continue;
        if (snuggest == -1 || standing[pile] < standing[snuggest]) {
          snuggest = pile;
        }
      }
      if (snuggest == -1) {
        standing.add(tod);
      } else {
        standing[snuggest] = tod;
      }
    }
    return standing.length;
  }

  /// The fewest piles the morning can end in from here, by trying every
  /// legal placement of every bale still to come. Nothing about a pile
  /// matters to the future but its top, so that is all the memo keys on.
  static int byBrute(List<int> tops, List<int> coming) =>
      _brute([...tops]..sort(), coming, 0, <String, int>{});

  static int _brute(
    List<int> tops,
    List<int> coming,
    int at,
    Map<String, int> seen,
  ) {
    if (at == coming.length) return tops.length;
    final key = '${tops.join(',')}|$at';
    final kept = seen[key];
    if (kept != null) return kept;

    final tod = coming[at];
    // On the ground is always legal.
    var fewest = _brute(
      [...tops, tod]..sort(),
      coming,
      at + 1,
      seen,
    );
    // On any pile whose top can take it, skipping tops of the same weight:
    // two piles with equal tops have identical futures.
    for (var pile = 0; pile < tops.length; pile++) {
      if (tops[pile] <= tod) continue;
      if (pile > 0 && tops[pile] == tops[pile - 1]) continue;
      final after = [...tops]..[pile] = tod;
      after.sort();
      final ends = _brute(after, coming, at + 1, seen);
      if (ends < fewest) fewest = ends;
    }
    return seen[key] = fewest;
  }
}
