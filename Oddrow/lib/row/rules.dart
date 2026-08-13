/// The law of the triangle.
///
/// Pascal's triangle, row nought to row fifteen, and in every
/// row the odd numbers counted. Lucas' 1878 law reads the
/// count without a single addition: an entry is odd exactly
/// when its place's bits fit inside the row's bits, so the
/// odds number two to the power of the row's lit bits. Powers
/// of two only: no row anywhere holds exactly three.
class Rules {
  /// The last row on the wall.
  static const top = 15;

  /// A row of the triangle, built by Pascal's own addition.
  static List<int> row(int at) {
    var held = [1];
    for (var r = 1; r <= at; r++) {
      held = [
        1,
        for (var k = 0; k + 1 < held.length; k++)
          held[k] + held[k + 1],
        1,
      ];
    }
    return held;
  }

  /// The odd entries of a row, by the addition itself.
  static List<int> oddPlaces(int at) => [
        for (var k = 0; k < at + 1; k++)
          if (row(at)[k].isOdd) k,
      ];

  /// How many entries of a row are odd, by the addition.
  static int oddsByRow(int at) => oddPlaces(at).length;

  /// The same count by Lucas' bit rule, no addition anywhere:
  /// a place is odd when its bits fit inside the row's.
  static int oddsByBits(int at) {
    var odds = 0;
    for (var k = 0; k <= at; k++) {
      if (k & at == k) odds++;
    }
    return odds;
  }

  /// The same count a third way: one doubling per lit bit.
  static int oddsByDoubling(int at) {
    var odds = 1;
    var left = at;
    while (left > 0) {
      if (left & 1 == 1) odds *= 2;
      left >>= 1;
    }
    return odds;
  }

  /// How many rows on the wall hold exactly [asked] odds.
  static int waysTo(int asked) {
    var ways = 0;
    for (var at = 0; at <= top; at++) {
      if (oddsByRow(at) == asked) ways++;
    }
    return ways;
  }

  /// The rows holding exactly [asked] odds.
  static List<int> rowsWith(int asked) => [
        for (var at = 0; at <= top; at++)
          if (oddsByRow(at) == asked) at,
      ];

  /// The three counts held together over every row of the
  /// wall, and the tally pinned. True when nothing breaks.
  static bool lawsHold() {
    final tally = <int, int>{};
    for (var at = 0; at <= top; at++) {
      final byRow = oddsByRow(at);
      if (byRow != oddsByBits(at)) return false;
      if (byRow != oddsByDoubling(at)) return false;
      tally[byRow] = (tally[byRow] ?? 0) + 1;
    }
    return '${Map.fromEntries(tally.entries.toList()..sort((a, b) => a.key - b.key))}' ==
        '{1: 1, 2: 4, 4: 6, 8: 4, 16: 1}';
  }
}
