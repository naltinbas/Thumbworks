/// A ticket of five digits, the last the check digit, and Luhn's rule
/// of 1954: from the right, double every second digit, taking nine off
/// a double past nine, add the lot, and the ticket passes when the sum
/// ends in nought. One slip of a digit is always caught; a swap of two
/// neighbours is caught unless they are 0 and 9; and a twin pair 22, 33
/// or 44 turned to 55, 66 or 77, or back, slips through.
class Rules {
  static const places = 5;

  /// Every ticket, as its digits, 00000 first.
  static Iterable<List<int>> get tickets sync* {
    for (var n = 0; n < count; n++) {
      yield digitsOf(n);
    }
  }

  static int get count => 100000;

  static List<int> digitsOf(int n) => [for (var i = places - 1; i >= 0; i--) (n ~/ pow10(i)) % 10];

  static int numberOf(List<int> d) => d.fold(0, (a, b) => a * 10 + b);

  static int pow10(int k) {
    var p = 1;
    for (var i = 0; i < k; i++) {
      p *= 10;
    }
    return p;
  }

  /// A digit doubled by Luhn: twice it, less nine when that passes nine.
  static int doubled(int d) => 2 * d > 9 ? 2 * d - 9 : 2 * d;

  /// Whether the digit at [place], 0 the leftmost, is doubled: every
  /// second one from the right, the check digit not.
  static bool isDoubled(int place) => (places - 1 - place).isOdd;

  /// What each digit adds to the sum.
  static List<int> adds(List<int> d) => [for (var i = 0; i < places; i++) isDoubled(i) ? doubled(d[i]) : d[i]];

  /// Luhn's sum: the first voice.
  static int sum(List<int> d) => adds(d).fold(0, (a, b) => a + b);

  static bool passes(List<int> d) => sum(d) % 10 == 0;

  /// The check digit that makes the first four digits pass.
  static int checkFor(List<int> d) {
    final rest = sum([...d.sublist(0, places - 1), 0]);
    return (10 - rest % 10) % 10;
  }

  /// The doubling as a table, the second voice: 0, 2, 4, 6, 8, 1, 3, 5,
  /// 7, 9, every digit once, so two different digits never double to
  /// the same, and a slip in a doubled place moves the sum as surely as
  /// one in a plain place.
  static const doubles = [0, 2, 4, 6, 8, 1, 3, 5, 7, 9];

  /// What a digit adds with its doubled self, the second voice for
  /// twins: 0, 3, 6, 9, 2, 6, 9, 2, 5, 8 by ten, so 2 and 5, 3 and 6,
  /// 4 and 7 add alike, and a twin pair of the one turned to the other
  /// slips through.
  static int withDouble(int d) => (d + doubles[d]) % 10;

  /// The pairs of different digits that swap unseen: a in a plain place
  /// and b in a doubled beside it add like b and a do exactly when
  /// a + 2b and b + 2a agree by ten, less nine where the double passes
  /// nine, and only 0 and 9 do.
  static List<(int, int)> get swapUnseen => [
        for (var a = 0; a < 10; a++)
          for (var b = 0; b < 10; b++)
            if (a != b && (a + doubles[b]) % 10 == (b + doubles[a]) % 10) (a, b),
      ];

  /// The pairs of different digits whose twins slip: aa and bb add
  /// alike by ten.
  static List<(int, int)> get twinsUnseen => [
        for (var a = 0; a < 10; a++)
          for (var b = a + 1; b < 10; b++)
            if (withDouble(a) == withDouble(b)) (a, b),
      ];

  static String tell(List<int> d) => d.join(' ');
}
