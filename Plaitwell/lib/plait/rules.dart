/// A plait of ropes, its crossings, and the painting rule that goes with it.
///
/// A plait is written as a word: a list of turns, one per crossing, read from
/// the top down. A turn of `k` crosses the rope in lane k over the rope in
/// lane k+1, and a turn of `-k` crosses it under. The bottom of the plait is
/// joined back to the top, lane for lane, so the ropes close into loops.
///
/// An arc is a length of rope that runs over crossings without interruption
/// and ends wherever the rope dives under. Painting is done arc by arc, and
/// the rule at every crossing is that the three arc ends meeting there are
/// all one colour or all three different.
///
/// Everything here is whole numbers and remainders by three.
class Rules {
  /// The colours a rope can take.
  static const colours = 3;

  /// The plait as it is drawn: which arc lies on each lane at each height.
  ///
  /// `lanes[height][lane]` is the arc number of the piece of rope on that
  /// lane at that height, with heights running 0 at the top to the number of
  /// crossings at the bottom.
  static List<List<int>> lanes(int strands, List<int> word) {
    final rows = <List<int>>[
      [for (var j = 0; j < strands; j++) j],
    ];
    var next = strands;
    for (final turn in word) {
      final i = turn.abs() - 1;
      final here = [...rows.last];
      final left = here[i], right = here[i + 1];
      if (turn > 0) {
        // The left rope passes over; the right one dives under and its arc
        // ends there.
        here[i] = next++;
        here[i + 1] = left;
      } else {
        here[i] = right;
        here[i + 1] = next++;
      }
      rows.add(here);
    }
    return _closed(strands, rows);
  }

  /// Joins the bottom of the plait back to the top and renumbers the arcs
  /// from nought upward.
  static List<List<int>> _closed(int strands, List<List<int>> rows) {
    final most = rows.expand((r) => r).fold(0, (a, b) => a > b ? a : b) + 1;
    final root = [for (var i = 0; i < most; i++) i];
    int find(int x) {
      var here = x;
      while (root[here] != here) {
        root[here] = root[root[here]];
        here = root[here];
      }
      return here;
    }

    void join(int a, int b) {
      final x = find(a), y = find(b);
      if (x != y) root[x] = y;
    }

    for (var j = 0; j < strands; j++) {
      join(rows.last[j], rows.first[j]);
    }
    final names = <int, int>{};
    for (final row in rows) {
      for (final arc in row) {
        names.putIfAbsent(find(arc), () => names.length);
      }
    }
    return [
      for (final row in rows) [for (final arc in row) names[find(arc)]!],
    ];
  }

  /// How many arcs the plait has.
  static int arcs(int strands, List<int> word) {
    final rows = lanes(strands, word);
    var most = 0;
    for (final row in rows) {
      for (final arc in row) {
        if (arc > most) most = arc;
      }
    }
    return most + 1;
  }

  /// Every crossing as (the arc passing over, the arc diving under, the arc
  /// coming out the far side).
  static List<(int, int, int)> crossings(int strands, List<int> word) {
    final rows = lanes(strands, word);
    final out = <(int, int, int)>[];
    for (var r = 0; r < word.length; r++) {
      final i = word[r].abs() - 1;
      if (word[r] > 0) {
        out.add((rows[r][i], rows[r][i + 1], rows[r + 1][i]));
      } else {
        out.add((rows[r][i + 1], rows[r][i], rows[r + 1][i + 1]));
      }
    }
    return out;
  }

  /// Whether the three arc ends at a crossing sit right: all one colour, or
  /// all three different. Written as arithmetic, twice the over arc has to
  /// match the two under ends added, counting by threes.
  static bool sound((int, int, int) crossing, List<int> paint) =>
      (2 * paint[crossing.$1] - paint[crossing.$2] - paint[crossing.$3]) % 3 ==
          0;

  /// Whether every crossing of a plait sits right.
  static bool legal(List<(int, int, int)> crossings, List<int> paint) {
    for (final crossing in crossings) {
      if (!sound(crossing, paint)) return false;
    }
    return true;
  }

  /// The crossings a painting gets wrong.
  static List<int> wrong(List<(int, int, int)> crossings, List<int> paint) => [
        for (var k = 0; k < crossings.length; k++)
          if (!sound(crossings[k], paint)) k,
      ];

  /// Whether a painting uses all three colours.
  static bool full(List<int> paint) => paint.toSet().length == colours;

  /// Every painting of the arcs that keeps the rule, counted rather than
  /// listed. There are three to the number of arcs to look at.
  static int paintings(List<(int, int, int)> crossings, int arcs,
      {bool allThree = false}) {
    var found = 0;
    final paint = List.filled(arcs, 0);
    void walk(int at) {
      if (at == arcs) {
        if (!legal(crossings, paint)) return;
        if (allThree && !full(paint)) return;
        found++;
        return;
      }
      for (var c = 0; c < colours; c++) {
        paint[at] = c;
        walk(at + 1);
      }
      paint[at] = 0;
    }

    walk(0);
    return found;
  }

  /// Every painting that keeps the rule and uses all three colours.
  static List<List<int>> proper(List<(int, int, int)> crossings, int arcs) {
    final out = <List<int>>[];
    final paint = List.filled(arcs, 0);
    void walk(int at) {
      if (at == arcs) {
        if (legal(crossings, paint) && full(paint)) out.add([...paint]);
        return;
      }
      for (var c = 0; c < colours; c++) {
        paint[at] = c;
        walk(at + 1);
      }
      paint[at] = 0;
    }

    walk(0);
    return out;
  }

  /// The taps between two paintings. One tap steps an arc on a colour, and
  /// the colours come round in a ring, so it is the step from one to the
  /// other counted forward.
  static int between(List<int> from, List<int> to) {
    var taps = 0;
    for (var i = 0; i < from.length; i++) {
      taps += (to[i] - from[i]) % colours;
    }
    return taps;
  }

  /// How many separate ropes the plait closes into.
  static int ropes(int strands, List<int> word) {
    final ends = [for (var j = 0; j < strands; j++) j];
    for (final turn in word) {
      final i = turn.abs() - 1;
      final held = ends[i];
      ends[i] = ends[i + 1];
      ends[i + 1] = held;
    }
    final seen = <int>{};
    var count = 0;
    for (var j = 0; j < strands; j++) {
      if (seen.contains(j)) continue;
      count++;
      var k = j;
      while (!seen.contains(k)) {
        seen.add(k);
        k = ends[k];
      }
    }
    return count;
  }
}
