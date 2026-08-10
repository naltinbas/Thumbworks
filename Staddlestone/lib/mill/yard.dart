/// A yard: three staddles, and some millstones stacked on the first.
///
/// A move takes the top stone of one staddle and sets it on another, and a
/// bigger stone never goes on a smaller. That is the whole of the rules.
class Yard {
  const Yard({required this.name, required this.stones, required this.fewest});

  final String name;

  /// How many stones, numbered 0 for the smallest.
  final int stones;

  /// The fewest moves from all-on-the-first to all-on-the-last. Written down
  /// here as well as worked out, so a test can hold the two against each
  /// other, and it had better be one less than two to the stones.
  final int fewest;
}

/// Where every stone stands: staddle 0, 1 or 2, smallest stone first.
///
/// A stone's position is all that matters, because the stones on any staddle
/// always sit in order of size, so which staddle each stone is on says
/// everything there is to say.
class Standing {
  Standing(this.on) : assert(on.length <= 10);

  final List<int> on;

  int get stones => on.length;

  /// The top stone of a staddle, or -1 for a bare staddle.
  int topOf(int staddle) {
    for (var stone = 0; stone < stones; stone++) {
      if (on[stone] == staddle) return stone;
    }
    return -1;
  }

  /// Whether the top of [from] can be set on [to].
  bool canMove(int from, int to) {
    if (from == to) return false;
    final lifting = topOf(from);
    if (lifting < 0) return false;
    final landing = topOf(to);
    return landing < 0 || lifting < landing;
  }

  Standing move(int from, int to) {
    final next = List.of(on);
    next[topOf(from)] = to;
    return Standing(next);
  }

  /// Every standing as one number, three positions a stone.
  int get key {
    var packed = 0;
    for (var stone = stones - 1; stone >= 0; stone--) {
      packed = packed * 3 + on[stone];
    }
    return packed;
  }

  static Standing unpack(int key, int stones) {
    final on = <int>[];
    var left = key;
    for (var stone = 0; stone < stones; stone++) {
      on.add(left % 3);
      left ~/= 3;
    }
    return Standing(on);
  }

  bool get allOnLast => on.every((staddle) => staddle == 2);
}
