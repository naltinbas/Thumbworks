/// The law of the watch.
///
/// A ring is lanterns round a circle, lit or dark, read as bits. A
/// watchword is the run of so many lanterns starting at each place,
/// read clockwise. The watch is full when every place spells a
/// different word, which at the right length means every word there
/// is, exactly once round the ring.
///
/// Everything the game claims comes two ways that share nothing: the
/// old shift-walk that builds a full ring edge by edge, and a sweep of
/// every ring there is that counts the full ones.
class Rules {
  Rules(this.watch, this.length);

  /// How many lanterns a watchword spans.
  final int watch;

  /// How many lanterns round the ring.
  final int length;

  int get words => 1 << watch;

  /// The word starting at a place, read clockwise.
  int wordAt(int ring, int place) {
    var word = 0;
    for (var step = 0; step < watch; step++) {
      final at = (place + step) % length;
      word = (word << 1) | ((ring >> at) & 1);
    }
    return word;
  }

  /// Every place's word, in place order.
  List<int> allWords(int ring) => [
        for (var place = 0; place < length; place++) wordAt(ring, place),
      ];

  /// The distinct words spelt, as a mask.
  int spelt(int ring) {
    var mask = 0;
    for (var place = 0; place < length; place++) {
      mask |= 1 << wordAt(ring, place);
    }
    return mask;
  }

  /// How many distinct words the ring spells.
  int speltCount(int ring) {
    var mask = spelt(ring);
    var count = 0;
    while (mask != 0) {
      mask &= mask - 1;
      count++;
    }
    return count;
  }

  /// Whether the watch is full: every word there is, spelt somewhere.
  bool isFull(int ring) => spelt(ring) == (1 << words) - 1;

  /// The clashes: pairs of places spelling the same word.
  List<(int, int)> clashes(int ring) {
    final words = allWords(ring);
    return [
      for (var one = 0; one < length; one++)
        for (var other = one + 1; other < length; other++)
          if (words[one] == words[other]) (one, other),
    ];
  }

  /// Every ring of this length.
  Iterable<int> allRings() sync* {
    for (var ring = 0; ring < (1 << length); ring++) {
      yield ring;
    }
  }

  /// How many rings are full, swept outright.
  int fullCount() {
    var count = 0;
    for (final ring in allRings()) {
      if (isFull(ring)) count++;
    }
    return count;
  }

  /// The full rings agreeing with locked lanterns, swept.
  List<int> fullRingsUnder(int lockedPlaces, int lockedBits) => [
        for (final ring in allRings())
          if ((ring & lockedPlaces) == (lockedBits & lockedPlaces) &&
              isFull(ring))
            ring,
      ];

  /// The shift-walk: every word of one fewer lanterns is a corner, and
  /// each word there is is a road from its head to its tail. Every
  /// corner has two roads in and two out, so one round trip walks every
  /// road once, and reading the roads' last bits round the trip is a
  /// full ring. Built here edge by edge, knowing nothing of sweeps.
  int byShiftWalk() {
    final corners = 1 << (watch - 1);
    final usedRoads = List<int>.filled(corners, 0);
    final trail = <int>[];
    final stack = <int>[0];
    // Hierholzer: push corners, take unused roads, back out writing.
    while (stack.isNotEmpty) {
      final at = stack.last;
      var took = -1;
      for (var bit = 0; bit < 2; bit++) {
        if (usedRoads[at] & (1 << bit) == 0) {
          took = bit;
          break;
        }
      }
      if (took < 0) {
        trail.add(at);
        stack.removeLast();
      } else {
        usedRoads[at] |= 1 << took;
        stack.add(((at << 1) | took) & (corners - 1));
      }
    }
    // The trail is the trip backwards; its steps' low bits are the
    // ring.
    var ring = 0;
    for (var step = 0; step < trail.length - 1; step++) {
      ring |= (trail[step] & 1) << step;
    }
    return ring;
  }
}
