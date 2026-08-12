/// The law of the yard.
///
/// Chickens stand in a ring, and every pair has settled who
/// pecks whom. A king pecks every other chicken in two steps at
/// most: outright, or through one middleman. Landau's 1953 law
/// says every pecking crowns somebody, and the busiest pecker
/// always wears one; Moon's law says no pecking anywhere crowns
/// exactly two. The sweep tries every orientation there is, 8
/// and 64 and 1,024, and holds every law on every one.
class Rules {
  Rules(this.chickens)
      : pairs = [
          for (var a = 0; a < chickens; a++)
            for (var b = a + 1; b < chickens; b++) (a, b),
        ];

  final int chickens;

  /// Every pair of the yard, low chicken first.
  final List<(int, int)> pairs;

  /// A pecking is one bool per pair: false, the low chicken
  /// pecks the high one; true, the high pecks the low.
  List<List<bool>> table(List<bool> pecking) {
    final pecks = [
      for (var a = 0; a < chickens; a++)
        List.filled(chickens, false),
    ];
    for (var at = 0; at < pairs.length; at++) {
      final (a, b) = pairs[at];
      if (pecking[at]) {
        pecks[b][a] = true;
      } else {
        pecks[a][b] = true;
      }
    }
    return pecks;
  }

  /// How many each chicken pecks outright.
  List<int> outPecks(List<bool> pecking) {
    final pecks = table(pecking);
    return [
      for (var a = 0; a < chickens; a++)
        pecks[a].where((pecked) => pecked).length,
    ];
  }

  /// The kings by the definition: every other chicken reached
  /// in one step or two.
  List<int> kings(List<bool> pecking) {
    final pecks = table(pecking);
    final crowned = <int>[];
    for (var k = 0; k < chickens; k++) {
      var reigns = true;
      for (var other = 0; other < chickens && reigns; other++) {
        if (other == k || pecks[k][other]) continue;
        var reached = false;
        for (var mid = 0; mid < chickens && !reached; mid++) {
          reached = pecks[k][mid] && pecks[mid][other];
        }
        reigns = reached;
      }
      if (reigns) crowned.add(k);
    }
    return crowned;
  }

  /// The kings a second way: square the pecking table and ask
  /// for full rows of the one-or-two-step reach.
  List<int> kingsBySquare(List<bool> pecking) {
    final pecks = table(pecking);
    final crowned = <int>[];
    for (var k = 0; k < chickens; k++) {
      final reach = List.of(pecks[k]);
      for (var mid = 0; mid < chickens; mid++) {
        if (!pecks[k][mid]) continue;
        for (var far = 0; far < chickens; far++) {
          if (pecks[mid][far]) reach[far] = true;
        }
      }
      var whole = true;
      for (var other = 0; other < chickens; other++) {
        if (other != k && !reach[other]) whole = false;
      }
      if (whole) crowned.add(k);
    }
    return crowned;
  }

  /// The emperors: chickens that peck everyone outright.
  List<int> emperors(List<bool> pecking) {
    final out = outPecks(pecking);
    return [
      for (var a = 0; a < chickens; a++)
        if (out[a] == chickens - 1) a,
    ];
  }

  /// Every pecking of the yard, walked; calls [visit] with each.
  /// The sweep the checker and the suite share.
  void peckings(void Function(List<bool>) visit) {
    final pecking = List.filled(pairs.length, false);
    void flip(int from) {
      if (from == pairs.length) {
        visit(pecking);
        return;
      }
      pecking[from] = false;
      flip(from + 1);
      pecking[from] = true;
      flip(from + 1);
    }

    flip(0);
  }

  /// How many peckings crown exactly [asked] kings.
  int waysTo(int asked) {
    var ways = 0;
    peckings((pecking) {
      if (kings(pecking).length == asked) ways++;
    });
    return ways;
  }

  /// The crown counts over every pecking, spread by count.
  Map<int, int> spread() {
    final counts = <int, int>{};
    peckings((pecking) {
      final crowns = kings(pecking).length;
      counts[crowns] = (counts[crowns] ?? 0) + 1;
    });
    return counts;
  }

  /// The laws, held over every pecking: the two king counts
  /// agree, the busiest pecker is crowned, a lone king is an
  /// emperor, an emperor stands alone, and no pecking crowns
  /// exactly two. True when nothing breaks.
  bool lawsHold() {
    var sound = true;
    peckings((pecking) {
      final crowned = kings(pecking);
      final again = kingsBySquare(pecking);
      if ('$crowned' != '$again') sound = false;
      if (crowned.length == 2) sound = false;
      final out = outPecks(pecking);
      var best = 0;
      for (final count in out) {
        if (count > best) best = count;
      }
      for (var a = 0; a < chickens; a++) {
        if (out[a] == best && !crowned.contains(a)) sound = false;
      }
      final crownedEmperors = emperors(pecking);
      if (crowned.length == 1 && crownedEmperors.isEmpty) {
        sound = false;
      }
      if (crownedEmperors.isNotEmpty && crowned.length != 1) {
        sound = false;
      }
    });
    return sound;
  }

  /// The fewest flips from [pecking] to a pecking crowning
  /// [asked] kings, walked breadth-first; null when none lands.
  List<int>? flipsTo(List<bool> pecking, int asked) {
    int encode(List<bool> bits) {
      var word = 0;
      for (var at = 0; at < bits.length; at++) {
        if (bits[at]) word |= 1 << at;
      }
      return word;
    }

    final start = encode(pecking);
    final seen = {start: -1};
    final walked = {start: -1};
    var edge = [start];
    if (kings(pecking).length == asked) return const [];
    while (edge.isNotEmpty) {
      final next = <int>[];
      for (final at in edge) {
        for (var flip = 0; flip < pairs.length; flip++) {
          final to = at ^ (1 << flip);
          if (seen.containsKey(to)) continue;
          seen[to] = at;
          walked[to] = flip;
          final bits = [
            for (var b = 0; b < pairs.length; b++) (to >> b) & 1 == 1,
          ];
          if (kings(bits).length == asked) {
            final road = <int>[];
            var here = to;
            while (here != start) {
              road.add(walked[here]!);
              here = seen[here]!;
            }
            return road.reversed.toList();
          }
          next.add(to);
        }
      }
      edge = next;
    }
    return null;
  }
}
