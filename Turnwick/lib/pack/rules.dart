/// A card in the pack: which card, and whether it lies face up.
typedef Card = (int, bool);

/// The law of the pack: an even number of cards, all face down to
/// start, and two moves. Cut: the top card goes to the bottom. Turn:
/// the top two cards are turned over as one, so they swap places and
/// both flip. Hummer's principle: the cards face up at even places
/// always number the cards face up at odd places, so a pattern of faces
/// comes only if it keeps that count.
class Rules {
  const Rules(this.cards);

  /// Cards in the pack, an even number.
  final int cards;

  List<Card> get start => [for (var i = 0; i < cards; i++) (i, false)];

  static List<Card> cut(List<Card> pack) => [...pack.sublist(1), pack[0]];

  static List<Card> turn(List<Card> pack) => [(pack[1].$1, !pack[1].$2), (pack[0].$1, !pack[0].$2), ...pack.sublist(2)];

  static List<Card> move(List<Card> pack, bool turning) => turning ? turn(pack) : cut(pack);

  /// The faces, top down: true for up.
  static List<bool> faces(List<Card> pack) => [for (final c in pack) c.$2];

  /// The cards face up at even places, counting the top as place nought.
  static int upAtEven(List<bool> faces) => [for (var i = 0; i < faces.length; i += 2) if (faces[i]) i].length;

  /// The cards face up at odd places.
  static int upAtOdd(List<bool> faces) => [for (var i = 1; i < faces.length; i += 2) if (faces[i]) i].length;

  /// Hummer's count: as many up at even places as at odd.
  static bool balanced(List<bool> faces) => upAtEven(faces) == upAtOdd(faces);

  static String key(List<Card> pack) => pack.map((c) => '${c.$1}${c.$2 ? 'u' : 'd'}').join(',');

  static String faceKey(List<bool> faces) => faces.map((f) => f ? '1' : '0').join();

  /// The walk: every pack reachable from all face down, with the fewest
  /// moves to each.
  Map<String, int> walk() {
    if (_walks.containsKey(cards)) return _walks[cards]!;
    final seen = <String, int>{key(start): 0};
    final queue = [start];
    var head = 0;
    while (head < queue.length) {
      final p = queue[head++];
      final d = seen[key(p)]!;
      for (final t in [cut(p), turn(p)]) {
        final k = key(t);
        if (!seen.containsKey(k)) {
          seen[k] = d + 1;
          queue.add(t);
        }
      }
    }
    return _walks[cards] = seen;
  }

  static final _walks = <int, Map<String, int>>{};

  /// The face patterns reached, with the fewest moves to each.
  Map<String, int> patterns() {
    final out = <String, int>{};
    for (final e in walk().entries) {
      final k = faceKey(e.key.split(',').map((c) => c.endsWith('u')).toList());
      if (!out.containsKey(k) || out[k]! > e.value) out[k] = e.value;
    }
    return out;
  }

  /// The fewest moves to a face pattern, or null when it never comes.
  int? fewest(List<bool> pattern) => patterns()[faceKey(pattern)];

  /// Every pattern of faces that keeps Hummer's count: (balanced, all).
  (int, int) balancedPatterns() {
    var balanced = 0;
    for (var mask = 0; mask < (1 << cards); mask++) {
      final faces = [for (var i = 0; i < cards; i++) (mask >> i) & 1 == 1];
      if (Rules.balanced(faces)) balanced++;
    }
    return (balanced, 1 << cards);
  }

  /// Every sequence of exactly [moves] moves from the start, with those
  /// ending on [pattern] counted: (landing, all).
  (int, int) sweep(List<bool> pattern, int moves) {
    final want = faceKey(pattern);
    var landing = 0, all = 0;
    void go(List<Card> pack, int left) {
      if (left == 0) {
        all++;
        if (faceKey(faces(pack)) == want) landing++;
        return;
      }
      go(cut(pack), left - 1);
      go(turn(pack), left - 1);
    }

    go(start, moves);
    return (landing, all);
  }

  /// A shortest road from [pack] to [pattern], as turnings, or null.
  static List<bool>? road(List<Card> pack, List<bool> pattern) {
    final want = faceKey(pattern);
    if (faceKey(faces(pack)) == want) return const [];
    final seen = <String, (String, bool)?>{key(pack): null};
    final queue = [pack];
    var head = 0;
    while (head < queue.length) {
      final p = queue[head++];
      for (final turning in [false, true]) {
        final t = move(p, turning);
        final k = key(t);
        if (seen.containsKey(k)) continue;
        seen[k] = (key(p), turning);
        if (faceKey(faces(t)) == want) {
          final out = <bool>[];
          var x = k;
          while (x != key(pack)) {
            final (from, tn) = seen[x]!;
            out.add(tn);
            x = from;
          }
          return out.reversed.toList();
        }
        queue.add(t);
      }
    }
    return null;
  }
}
