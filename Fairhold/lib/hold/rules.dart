/// The reduction, the check, and the search.
///
/// Four crates, each painted on six faces in four paints, to be stacked
/// so each long side of the stack shows all four paints. A crate in the
/// stack offers one opposite-face pair to the north-south line and a
/// different pair to the east-west line; the top-bottom pair sits idle.
///
/// The old reduction: think of the paints as four posts and each
/// crate's three opposite-face pairs as three ropes between posts. Pick
/// one rope per crate for north-south so that every post holds exactly
/// two rope-ends, and another rope per crate, none reused, likewise for
/// east-west. Around a line where every post holds two ends, the crates
/// can always be turned so each paint shows once each way, and that is
/// the whole puzzle.
///
/// The search tries all assignments, six per crate, and counts. The
/// counting floor: a paint on fewer than four faces among the pairs can
/// never hold two ends on both lines, and one shipped consignment fails
/// exactly there.
class Rules {
  const Rules._();

  /// Whether an axis's chosen pairs sit every paint at exactly two
  /// ends. [pairs] holds one (a, b) rope per crate.
  static bool fair(List<(int, int)> pairs) {
    final ends = List<int>.filled(4, 0);
    for (final (a, b) in pairs) {
      ends[a]++;
      ends[b]++;
    }
    return ends.every((count) => count == 2);
  }

  /// Every solution over [crates], each crate three pairs: a solution
  /// assigns per crate a north-south pair and a different east-west
  /// pair, both lines fair. Returned as lists of (nsIndex, ewIndex) per
  /// crate.
  static List<List<(int, int)>> solutions(
      List<List<(int, int)>> crates) {
    final out = <List<(int, int)>>[];
    final picks = List<(int, int)>.filled(crates.length, (0, 0));
    void walk(int crate) {
      if (crate == crates.length) {
        final ns = [
          for (var at = 0; at < crates.length; at++)
            crates[at][picks[at].$1],
        ];
        final ew = [
          for (var at = 0; at < crates.length; at++)
            crates[at][picks[at].$2],
        ];
        if (fair(ns) && fair(ew)) out.add([...picks]);
        return;
      }
      for (var ns = 0; ns < 3; ns++) {
        for (var ew = 0; ew < 3; ew++) {
          if (ns == ew) continue;
          picks[crate] = (ns, ew);
          walk(crate + 1);
        }
      }
    }

    walk(0);
    return out;
  }

  /// How many rope-ends each paint has in all, over every pair of every
  /// crate: the counting floor needs at least four each.
  static List<int> endsInAll(List<List<(int, int)>> crates) {
    final ends = List<int>.filled(4, 0);
    for (final crate in crates) {
      for (final (a, b) in crate) {
        ends[a]++;
        ends[b]++;
      }
    }
    return ends;
  }

  /// Whether a part-made assignment can still finish. Picks hold
  /// (ns, ew) with -1 for unchosen; a crate may have one or both.
  static bool canStillStack(
      List<List<(int, int)>> crates, List<(int, int)> picks) {
    bool walk(int crate, List<(int, int)> chosen) {
      if (crate == crates.length) {
        final ns = <(int, int)>[];
        final ew = <(int, int)>[];
        for (var at = 0; at < crates.length; at++) {
          ns.add(crates[at][chosen[at].$1]);
          ew.add(crates[at][chosen[at].$2]);
        }
        return fair(ns) && fair(ew);
      }
      final (haveNs, haveEw) = picks[crate];
      for (var ns = 0; ns < 3; ns++) {
        if (haveNs >= 0 && ns != haveNs) continue;
        for (var ew = 0; ew < 3; ew++) {
          if (ew == ns) continue;
          if (haveEw >= 0 && ew != haveEw) continue;
          chosen[crate] = (ns, ew);
          if (walk(crate + 1, chosen)) return true;
        }
      }
      return false;
    }

    return walk(0, List.filled(crates.length, (0, 0)));
  }

  /// Turns a fair line into facings: for each crate, which paint shows
  /// north and which south (or east and west). Every post holds two
  /// ends, so the ropes close into loops; walk each loop nose to tail
  /// and each paint is entered once and left once.
  static List<(int, int)>? orient(List<(int, int)> pairs) {
    if (!fair(pairs)) return null;
    final facing = List<(int, int)?>.filled(pairs.length, null);
    final used = List<bool>.filled(pairs.length, false);
    for (var start = 0; start < pairs.length; start++) {
      if (used[start]) continue;
      var at = start;
      var from = pairs[start].$1;
      while (true) {
        used[at] = true;
        final (a, b) = pairs[at];
        final to = a == from ? b : a;
        facing[at] = (from, to);
        // Find the next unused rope holding [to].
        var next = -1;
        for (var other = 0; other < pairs.length; other++) {
          if (used[other]) continue;
          if (pairs[other].$1 == to || pairs[other].$2 == to) {
            next = other;
            break;
          }
        }
        if (next < 0) break;
        at = next;
        from = to;
      }
    }
    return [for (final f in facing) f!];
  }
}
