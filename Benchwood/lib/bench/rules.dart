/// A joiner's bench with a few tool slots, a store down the yard and a
/// job card that calls for tools one at a time.
///
/// A tool already on the bench is a free grab. A tool that is not is a
/// walk to the store, and if the bench is full something has to be
/// carried back first. The only choice in the whole game is which tool
/// goes back.
///
/// Laszlo Belady showed in 1966 that one rule is unbeatable: carry back
/// the tool whose next call is furthest off, and no other way of
/// choosing makes fewer walks. It is a rule only somebody holding the
/// whole card can follow, which is why real benches use worse ones.
/// One of those, carrying back whatever has been down longest, can even
/// get worse when the bench gets bigger, which Belady, Nelson and
/// Shedler wrote up in 1969.
class Rules {
  /// Where a tool sits when it is not on the bench.
  static const inStore = -1;

  /// Whether [bench] holds [tool].
  static bool onBench(List<int> bench, int tool) => bench.contains(tool);

  /// Where the card calls [tool] next after [at], or the card's length
  /// when it never does.
  static int nextCall(List<int> card, int tool, int at) {
    for (var i = at + 1; i < card.length; i++) {
      if (card[i] == tool) return i;
    }
    return card.length;
  }

  /// The tool on the bench whose next call is furthest off, which is
  /// the one Belady's rule carries back. Ties go to the tool in the
  /// lowest slot.
  static int furthest(List<int> card, List<int> bench, int at) {
    var pick = 0, far = -1;
    for (var slot = 0; slot < bench.length; slot++) {
      final when = nextCall(card, bench[slot], at);
      if (when > far) {
        far = when;
        pick = slot;
      }
    }
    return pick;
  }

  /// The walks Belady's rule takes over the whole card: the first
  /// voice.
  static int walksByRule(List<int> card, int slots) {
    final bench = <int>[];
    var walks = 0;
    for (var at = 0; at < card.length; at++) {
      final want = card[at];
      if (bench.contains(want)) continue;
      walks++;
      if (bench.length < slots) {
        bench.add(want);
      } else {
        bench[furthest(card, bench, at)] = want;
      }
    }
    return walks;
  }

  /// The fewest walks any way of choosing can manage, worked out by
  /// trying every eviction from every standing: the second voice, which
  /// knows nothing of Belady's rule.
  static int fewestWalks(List<int> card, int slots) {
    final seen = <String, int>{};

    int go(int at, List<int> bench) {
      if (at == card.length) return 0;
      final key = '$at:${(List.of(bench)..sort()).join(',')}';
      final held = seen[key];
      if (held != null) return held;
      final want = card[at];
      int got;
      if (bench.contains(want)) {
        got = go(at + 1, bench);
      } else if (bench.length < slots) {
        got = 1 + go(at + 1, [...bench, want]);
      } else {
        var best = card.length + 1;
        for (var slot = 0; slot < bench.length; slot++) {
          final next = List.of(bench)..[slot] = want;
          final walks = 1 + go(at + 1, next);
          if (walks < best) best = walks;
        }
        got = best;
      }
      seen[key] = got;
      return got;
    }

    return go(0, const []);
  }

  /// The walks taken by carrying back whatever has been down longest,
  /// the rule a bench without the card would use.
  static int walksByOldest(List<int> card, int slots) {
    final bench = <int>[];
    var walks = 0;
    for (final want in card) {
      if (bench.contains(want)) continue;
      walks++;
      if (bench.length < slots) {
        bench.add(want);
      } else {
        bench
          ..removeAt(0)
          ..add(want);
      }
    }
    return walks;
  }

  /// Every way the card can be played out, counted: how many runs there
  /// are and how many of them keep to [target] walks or fewer.
  static (int, int) plays(List<int> card, int slots, int target) {
    var runs = 0, good = 0;

    void go(int at, List<int> bench, int walks) {
      if (at == card.length) {
        runs++;
        if (walks <= target) good++;
        return;
      }
      final want = card[at];
      if (bench.contains(want)) {
        go(at + 1, bench, walks);
      } else if (bench.length < slots) {
        go(at + 1, [...bench, want], walks + 1);
      } else {
        for (var slot = 0; slot < bench.length; slot++) {
          go(at + 1, List.of(bench)..[slot] = want, walks + 1);
        }
      }
    }

    go(0, const [], 0);
    return (runs, good);
  }

  /// Every job card of [length] calls drawing on at most [tools] tools,
  /// with the tools named in the order they are first called, so that
  /// renaming them makes no new cards.
  static Iterable<List<int>> cards(int length, int tools) sync* {
    final card = List.filled(length, 0);

    Iterable<List<int>> go(int at, int used) sync* {
      if (at == length) {
        yield List.of(card);
        return;
      }
      for (var tool = 0; tool <= used && tool < tools; tool++) {
        card[at] = tool;
        yield* go(at + 1, tool == used ? used + 1 : used);
      }
    }

    yield* go(0, 0);
  }

  /// A tool's name on the bench: A for the first called, B for the
  /// second.
  static String tellTool(int tool) =>
      String.fromCharCode('A'.codeUnitAt(0) + tool);

  /// A card told in tools: 'A B C A'.
  static String tellCard(List<int> card) => card.map(tellTool).join(' ');
}
