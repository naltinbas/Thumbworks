/// The law of the combe.
///
/// Cottages stand in a ring, and lines are wired cottage to
/// cottage. A wiring is a run when it joins every cottage into
/// one piece with not a line to spare: as many lines as cottages
/// less one, and no loop anywhere. A cottage on a single line is
/// a lane's end.
///
/// Two old facts rule the combe, checked more ways than one.
/// Cayley's: the runs on n cottages number n to the n minus two,
/// counted by the sweep and again through the Prufer code, every
/// run coding to a word and every word back to its run. And the
/// lane's ends: every run keeps at least two, since n minus one
/// lines share out two ends apiece and cannot give every cottage
/// two. The suite refuses the bake the moment any two part ways.
class Rules {
  Rules(this.cottages);

  final int cottages;

  /// Every line the combe could carry.
  List<(int, int)> get allLines => [
        for (var a = 0; a < cottages; a++)
          for (var b = a + 1; b < cottages; b++) (a, b),
      ];

  /// How many lines each cottage stands on.
  List<int> standings(List<(int, int)> lines) {
    final stood = List.filled(cottages, 0);
    for (final (a, b) in lines) {
      stood[a]++;
      stood[b]++;
    }
    return stood;
  }

  /// The lane's ends: cottages on exactly one line.
  List<int> lanesEnds(List<(int, int)> lines) {
    final stood = standings(lines);
    return [
      for (var at = 0; at < cottages; at++)
        if (stood[at] == 1) at,
    ];
  }

  /// The pieces the wiring falls into.
  int pieces(List<(int, int)> lines) {
    final parent = List.generate(cottages, (at) => at);
    int find(int at) {
      while (parent[at] != at) {
        parent[at] = parent[parent[at]];
        at = parent[at];
      }
      return at;
    }

    for (final (a, b) in lines) {
      parent[find(a)] = find(b);
    }
    return {for (var at = 0; at < cottages; at++) find(at)}.length;
  }

  /// Whether the lines loop: more lines than joins made.
  bool loops(List<(int, int)> lines) =>
      lines.length > cottages - pieces(lines);

  /// A run: one piece, no loop, lines exactly cottages less one.
  bool isRun(List<(int, int)> lines) =>
      lines.length == cottages - 1 &&
      pieces(lines) == 1 &&
      !loops(lines);

  /// Every wiring of [count] lines, walked; calls [visit] with
  /// each. The sweep the checker and the suite share.
  void wirings(int count, void Function(List<(int, int)>) visit) {
    final lines = allLines;
    final picked = <(int, int)>[];
    void walk(int from) {
      if (picked.length == count) {
        visit(picked);
        return;
      }
      for (var at = from; at < lines.length; at++) {
        picked.add(lines[at]);
        walk(at + 1);
        picked.removeLast();
      }
    }

    walk(0);
  }

  /// How many runs there are, full stop: Cayley's count, done
  /// the long way.
  int runs() {
    var count = 0;
    wirings(cottages - 1, (lines) {
      if (isRun(lines)) count++;
    });
    return count;
  }

  /// How many runs keep exactly [ends] lane's ends; any count
  /// when [ends] is null.
  int waysTo(int? ends) {
    var count = 0;
    wirings(cottages - 1, (lines) {
      if (!isRun(lines)) return;
      if (ends == null || lanesEnds(lines).length == ends) count++;
    });
    return count;
  }

  /// One run keeping [ends] lane's ends, or null.
  List<(int, int)>? run(int? ends) {
    List<(int, int)>? found;
    wirings(cottages - 1, (lines) {
      if (found != null || !isRun(lines)) return;
      if (ends == null || lanesEnds(lines).length == ends) {
        found = List.of(lines);
      }
    });
    return found;
  }

  /// The Prufer code of a run: strike the lowest lane's end and
  /// write down its neighbour, until two cottages stand.
  List<int> code(List<(int, int)> lines) {
    final beside = List.generate(cottages, (_) => <int>{});
    for (final (a, b) in lines) {
      beside[a].add(b);
      beside[b].add(a);
    }
    final word = <int>[];
    final gone = List.filled(cottages, false);
    for (var strike = 0; strike < cottages - 2; strike++) {
      var end = -1;
      for (var at = 0; at < cottages; at++) {
        if (!gone[at] && beside[at].length == 1) {
          end = at;
          break;
        }
      }
      final neighbour = beside[end].single;
      word.add(neighbour);
      gone[end] = true;
      beside[neighbour].remove(end);
      beside[end].clear();
    }
    return word;
  }

  /// The run a Prufer word decodes to.
  List<(int, int)> decode(List<int> word) {
    final left = List.filled(cottages, 1);
    for (final at in word) {
      left[at]++;
    }
    final lines = <(int, int)>[];
    final spare = List.of(left);
    for (final at in word) {
      var end = -1;
      for (var look = 0; look < cottages; look++) {
        if (spare[look] == 1) {
          end = look;
          break;
        }
      }
      lines.add(end < at ? (end, at) : (at, end));
      spare[end] = 0;
      spare[at]--;
    }
    final last = [
      for (var at = 0; at < cottages; at++)
        if (spare[at] == 1) at,
    ];
    lines.add((last[0], last[1]));
    return lines;
  }

  /// Whether every run codes and decodes back to itself.
  bool prufersHold() {
    var sound = true;
    wirings(cottages - 1, (lines) {
      if (!isRun(lines)) return;
      final back = decode(code(lines)).toSet();
      if (back.length != lines.length ||
          !lines.every(back.contains)) {
        sound = false;
      }
    });
    return sound;
  }
}
