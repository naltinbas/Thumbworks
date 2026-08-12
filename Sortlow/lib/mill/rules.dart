/// The law of the mill.
///
/// Four digits make a number; the mill turns it by arranging
/// the digits biggest-first and smallest-first and taking the
/// difference. Kaprekar's 1949 discovery: every four-digit
/// number whose digits are not all alike arrives at 6174, and
/// by the seventh turn at the latest; 6174 alone stands still.
/// The repdigits are barred at the door, collapsing to nought
/// in one turn.
class Rules {
  /// The mill stone.
  static const stone = 6174;

  /// One turn of the mill.
  static int turn(int number) {
    final digits = [
      number ~/ 1000,
      number ~/ 100 % 10,
      number ~/ 10 % 10,
      number % 10,
    ]..sort();
    final rising =
        digits[0] * 1000 + digits[1] * 100 + digits[2] * 10 + digits[3];
    final falling =
        digits[3] * 1000 + digits[2] * 100 + digits[1] * 10 + digits[0];
    return falling - rising;
  }

  /// Whether all four digits are alike: barred at the door.
  static bool repdigit(int number) {
    final digits = {
      number ~/ 1000,
      number ~/ 100 % 10,
      number ~/ 10 % 10,
      number % 10,
    };
    return digits.length == 1;
  }

  /// The road from a number to the stone, walked forward; the
  /// number itself first, the stone last.
  static List<int> road(int number) {
    final steps = [number];
    var at = number;
    while (at != stone && steps.length <= 9) {
      at = turn(at);
      steps.add(at);
    }
    return steps;
  }

  /// How many turns the walk takes.
  static int stepsByWalk(int number) => road(number).length - 1;

  static List<int>? _table;

  /// How many turns, read from the table built backwards from
  /// the stone, layer by layer: the second voice.
  static int stepsByTable(int number) {
    if (_table == null) {
      final table = List.filled(10000, -1);
      table[stone] = 0;
      var layer = [stone];
      var depth = 0;
      while (layer.isNotEmpty) {
        depth++;
        final next = <int>[];
        // Everything turning into this layer, found by turning
        // every allowed number once.
        for (var n = 0; n < 10000; n++) {
          if (repdigit(n) || table[n] != -1) continue;
          if (table[turn(n)] == depth - 1 ||
              (depth == 1 && turn(n) == stone)) {
            table[n] = depth;
            next.add(n);
          }
        }
        layer = next;
      }
      _table = table;
    }
    return _table![number];
  }

  /// Every allowed number, walked; calls [visit] with each.
  static void numbers(void Function(int) visit) {
    for (var n = 0; n < 10000; n++) {
      if (!repdigit(n)) visit(n);
    }
  }

  /// How many numbers stand exactly [asked] turns out.
  static int waysTo(int asked) {
    var ways = 0;
    numbers((n) {
      if (stepsByWalk(n) == asked) ways++;
    });
    return ways;
  }

  /// The laws over every allowed number: the walk and the table
  /// agree, everything arrives by seven, the stone alone stands
  /// still, and every repdigit collapses to nought. True when
  /// nothing breaks.
  static bool lawsHold() {
    var sound = true;
    numbers((n) {
      final walked = stepsByWalk(n);
      if (walked > 7) sound = false;
      if (walked != stepsByTable(n)) sound = false;
      if (turn(n) == n && n != stone) sound = false;
    });
    for (var digit = 0; digit <= 9; digit++) {
      if (turn(digit * 1111) != 0) sound = false;
    }
    return sound;
  }
}
