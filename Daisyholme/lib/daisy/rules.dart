/// The law of the circle.
///
/// People round a green, befriending in pairs. The asking is
/// always the same: every pair of people, friends or not, must
/// share exactly one common friend. Erdos, Renyi and Sos's 1966
/// law says every answer is a daisy, triangles sharing one
/// heart, so somebody is friends with everyone; and the pairing
/// lemma says every crowd that manages it is odd, since each
/// person's friends pair off around them.
class Rules {
  Rules(this.people)
      : pairs = [
          for (var a = 0; a < people; a++)
            for (var b = a + 1; b < people; b++) (a, b),
        ];

  final int people;

  /// Every pair of the circle, low person first.
  final List<(int, int)> pairs;

  /// The friendship table under a wiring, one bool per pair.
  List<List<bool>> table(List<bool> wired) {
    final friends = [
      for (var a = 0; a < people; a++) List.filled(people, false),
    ];
    for (var at = 0; at < pairs.length; at++) {
      if (wired[at]) {
        friends[pairs[at].$1][pairs[at].$2] = true;
        friends[pairs[at].$2][pairs[at].$1] = true;
      }
    }
    return friends;
  }

  /// How many common friends each pair shares.
  List<int> commons(List<bool> wired) {
    final friends = table(wired);
    return [
      for (final (a, b) in pairs)
        [
          for (var c = 0; c < people; c++)
            if (friends[a][c] && friends[b][c]) c,
        ].length,
    ];
  }

  /// Whether a wiring lands the asking: every pair sharing
  /// exactly one friend.
  bool lands(List<bool> wired) =>
      commons(wired).every((count) => count == 1);

  /// Every wiring of the circle, walked; calls [visit] with
  /// each. [given] pins some pairs wired. The sweep the checker
  /// and the suite share.
  void wirings(
    void Function(List<bool>) visit, {
    Set<int>? given,
  }) {
    final wired = List.filled(pairs.length, false);
    void wire(int from) {
      if (from == pairs.length) {
        visit(wired);
        return;
      }
      if (given != null && given.contains(from)) {
        wired[from] = true;
        wire(from + 1);
        return;
      }
      wired[from] = false;
      wire(from + 1);
      wired[from] = true;
      wire(from + 1);
    }

    wire(0);
  }

  /// How many wirings land, the sweep voice.
  int waysBySweep({Set<int>? given}) {
    var ways = 0;
    wirings((wired) {
      if (lands(wired)) ways++;
    }, given: given);
    return ways;
  }

  /// How many wirings land, the daisy voice: a heart wired to
  /// everyone, the rest paired into petals. Counted with no
  /// searching, hearts times pairings.
  int waysByDaisies() {
    if (people.isEven || people < 3) return 0;
    // A daisy of one petal is the triangle, and every one of
    // its three corners is a heart: the same wiring, counted
    // once.
    if (people == 3) return 1;
    var pairings = 1;
    for (var left = people - 1; left > 1; left -= 2) {
      pairings *= left - 1;
    }
    return people * pairings;
  }

  /// One landing wiring: person nought at the heart, petals in
  /// ring order. Drives the show-me.
  List<bool> daisy() {
    final wired = List.filled(pairs.length, false);
    for (var other = 1; other < people; other++) {
      wired[pairs.indexOf((0, other))] = true;
    }
    for (var petal = 1; petal + 1 < people; petal += 2) {
      wired[pairs.indexOf((petal, petal + 1))] = true;
    }
    return wired;
  }

  /// The pairing lemma, executed on one landing: each person's
  /// friends pair off, everyone with the one common friend they
  /// share through the middle. True when the pairing is whole.
  bool friendsPairOff(List<bool> wired) {
    final friends = table(wired);
    for (var v = 0; v < people; v++) {
      final ring = [
        for (var u = 0; u < people; u++)
          if (friends[v][u]) u,
      ];
      if (ring.length.isOdd) return false;
      final paired = <int>{};
      for (final u in ring) {
        if (paired.contains(u)) continue;
        final partners = [
          for (final w in ring)
            if (w != u && friends[u][w]) w,
        ];
        if (partners.length != 1) return false;
        if (paired.contains(partners.first)) return false;
        paired.addAll([u, partners.first]);
      }
      if (paired.length != ring.length) return false;
    }
    return true;
  }

  /// The laws over every landing of the sweep: a heart wired to
  /// all, every degree even, the friends pairing off. True when
  /// nothing breaks.
  bool lawsHold() {
    var sound = true;
    wirings((wired) {
      if (!lands(wired)) return;
      final friends = table(wired);
      final degrees = [
        for (var v = 0; v < people; v++)
          friends[v].where((friend) => friend).length,
      ];
      if (!degrees.contains(people - 1)) sound = false;
      if (degrees.any((degree) => degree.isOdd)) sound = false;
      if (!friendsPairOff(wired)) sound = false;
    });
    return sound;
  }
}
