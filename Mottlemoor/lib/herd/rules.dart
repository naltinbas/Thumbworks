/// The law of the moor.
///
/// Chameleons wear one of three colours. When two of different
/// colours meet, both turn the third colour: the two herds shrink by
/// one each and the third grows by two. The moor is settled when one
/// herd holds everyone.
///
/// Which moors can settle is known two ways that share nothing: the
/// differences between herd counts never change their remainder by
/// three, and a walk of every herding tries everything outright.
class Rules {
  Rules(this.total) {
    _walk();
  }

  /// How many chameleons the moor holds.
  final int total;

  int pack(int a, int b) => a * (total + 1) + b;

  (int, int, int) unpack(int state) {
    final a = state ~/ (total + 1);
    final b = state % (total + 1);
    return (a, b, total - a - b);
  }

  bool isSettled((int, int, int) herds) =>
      herds.$1 == total || herds.$2 == total || herds.$3 == total;

  /// The herdings one meeting away: pairs of herds that can meet.
  List<(int, int)> meetings((int, int, int) herds) {
    final counts = [herds.$1, herds.$2, herds.$3];
    return [
      for (var one = 0; one < 3; one++)
        for (var other = one + 1; other < 3; other++)
          if (counts[one] > 0 && counts[other] > 0) (one, other),
    ];
  }

  /// One meeting between two herds.
  (int, int, int) met((int, int, int) herds, int one, int other) {
    final counts = [herds.$1, herds.$2, herds.$3];
    final third = 3 - one - other;
    counts[one]--;
    counts[other]--;
    counts[third] += 2;
    return (counts[0], counts[1], counts[2]);
  }

  late final List<int> _distance;

  void _walk() {
    final states = (total + 1) * (total + 1);
    _distance = List<int>.filled(states, -1);
    final edge = <int>[];
    for (var a = 0; a <= total; a++) {
      for (var b = 0; b + a <= total; b++) {
        if (isSettled((a, b, total - a - b))) {
          _distance[pack(a, b)] = 0;
          edge.add(pack(a, b));
        }
      }
    }
    var frontier = edge;
    while (frontier.isNotEmpty) {
      final next = <int>[];
      for (final state in frontier) {
        final herds = unpack(state);
        // Walk backwards: the moors one meeting BEFORE this one. A
        // meeting is its own reverse pattern: before (a,b,c) via
        // meeting one+other stood (a+1, b+1, c-2).
        for (var one = 0; one < 3; one++) {
          for (var other = one + 1; other < 3; other++) {
            final third = 3 - one - other;
            final counts = [herds.$1, herds.$2, herds.$3];
            counts[one]++;
            counts[other]++;
            counts[third] -= 2;
            if (counts[third] < 0) continue;
            if (counts[0] < 0 || counts[1] < 0 || counts[2] < 0) {
              continue;
            }
            if (counts[0] > total ||
                counts[1] > total ||
                counts[2] > total) {
              continue;
            }
            final before = pack(counts[0], counts[1]);
            if (_distance[before] != -1) continue;
            _distance[before] = _distance[state] + 1;
            next.add(before);
          }
        }
      }
      frontier = next;
    }
  }

  /// The fewest meetings from a herding to a settled moor, or null.
  int? fewest((int, int, int) herds) {
    final away = _distance[pack(herds.$1, herds.$2)];
    return away == -1 ? null : away;
  }

  /// Whether the differences allow settling: some two herds share a
  /// remainder by three.
  bool differencesAllow((int, int, int) herds) =>
      herds.$1 % 3 == herds.$2 % 3 ||
      herds.$2 % 3 == herds.$3 % 3 ||
      herds.$1 % 3 == herds.$3 % 3;

  /// A meeting that steps one nearer settling, or null.
  (int, int)? next((int, int, int) herds) {
    final here = fewest(herds);
    if (here == null || here == 0) return null;
    for (final (one, other) in meetings(herds)) {
      if (fewest(met(herds, one, other)) == here - 1) {
        return (one, other);
      }
    }
    return null;
  }
}
