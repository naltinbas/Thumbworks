/// The law of the hoop.
///
/// A hoop of so many holes round, a stride, and pegs hammered at
/// the stride's multiples: nought, one stride, two strides, on
/// round the hoop. The gaps between neighbouring pegs are measured
/// in holes.
///
/// What the gaps can do is known by one old law checked the long
/// way: however the stride and the count are dialed, the gaps only
/// ever take one, two, or three lengths, and when there are three
/// the longest is the other two put together. The sweep tries every
/// stride of every round and every count of pegs, and a fourth gap
/// size has never once shown.
class Rules {
  /// Where the pegs land: distinct multiples of the stride, in
  /// order round the hoop.
  static List<int> spots(int stride, int round, int pegs) {
    final landed = <int>{};
    for (var peg = 0; peg < pegs; peg++) {
      landed.add(peg * stride % round);
    }
    return landed.toList()..sort();
  }

  /// The gaps between neighbouring pegs, in holes.
  static List<int> gaps(int stride, int round, int pegs) {
    final at = spots(stride, round, pegs);
    return [
      for (var peg = 0; peg < at.length; peg++)
        (at[(peg + 1) % at.length] - at[peg]) % round == 0
            ? round
            : (at[(peg + 1) % at.length] - at[peg]) % round,
    ];
  }

  /// How many distinct gap lengths show.
  static int sizeCount(int stride, int round, int pegs) =>
      gaps(stride, round, pegs).toSet().length;

  /// Whether the longest of three gap lengths is the other two put
  /// together; true outright when fewer than three show.
  static bool sumLawHolds(int stride, int round, int pegs) {
    final sizes = gaps(stride, round, pegs).toSet().toList()..sort();
    if (sizes.length < 3) return true;
    return sizes[2] == sizes[0] + sizes[1];
  }

  /// Every dial that lands [pegs] distinct pegs showing exactly
  /// [asked] gap lengths, strides over rounds to [roundMost].
  static List<(int, int)> dialsThatGive(int pegs, int asked,
      {int roundMost = 12}) {
    final good = <(int, int)>[];
    for (var round = 2; round <= roundMost; round++) {
      for (var stride = 1; stride < round; stride++) {
        if (spots(stride, round, pegs).length != pegs) continue;
        if (sizeCount(stride, round, pegs) == asked) {
          good.add((stride, round));
        }
      }
    }
    return good;
  }

  /// Whether a fourth gap size ever shows, and whether the sum law
  /// ever breaks, over every dial to [roundMost] and every count to
  /// [pegsMost]. True when the law holds throughout.
  static bool lawHolds({int roundMost = 12, int pegsMost = 30}) {
    for (var round = 2; round <= roundMost; round++) {
      for (var stride = 1; stride < round; stride++) {
        for (var pegs = 1; pegs <= pegsMost; pegs++) {
          if (sizeCount(stride, round, pegs) > 3) return false;
          if (!sumLawHolds(stride, round, pegs)) return false;
        }
      }
    }
    return true;
  }
}
