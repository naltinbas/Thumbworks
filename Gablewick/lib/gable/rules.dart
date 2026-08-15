import 'dart:math';

/// The arithmetic of the gable: three whole sides, and whether the area
/// they enclose is a whole number. Two voices: Heron, sixteen times the
/// area squared being the product of the perimeter and the perimeter
/// less twice each side; and the height, the area squared being the
/// base squared times the height squared over four, the height found
/// from the foot of the perpendicular by Pythagoras, all in whole
/// numbers.
class Rules {
  /// The dials run from one to this.
  static const most = 15;

  /// Whether three sides close into a triangle.
  static bool closes(int a, int b, int c) => a + b > c && a + c > b && b + c > a;

  /// Sixteen times the area squared, by Heron.
  static int sixteenAreaSquared(int a, int b, int c) => (a + b + c) * (-a + b + c) * (a - b + c) * (a + b - c);

  /// Sixteen times the area squared, by the height: with c the base, the
  /// foot of the perpendicular from the far corner lies (b^2 + c^2 -
  /// a^2)/(2c) along it, so 4 c^2 h^2 = 4 b^2 c^2 - (b^2 + c^2 - a^2)^2.
  static int sixteenAreaSquaredByHeight(int a, int b, int c) => 4 * b * b * c * c - (b * b + c * c - a * a) * (b * b + c * c - a * a);

  /// The whole area, or null when the area is not whole: the sixteenfold
  /// square must be a perfect square whose root is a multiple of four.
  static int? wholeArea(int a, int b, int c) {
    if (!closes(a, b, c)) return null;
    final p = sixteenAreaSquared(a, b, c);
    final r = sqrt(p).round();
    if (r * r != p || r % 4 != 0) return null;
    return r ~/ 4;
  }

  /// The area as a double, for the picture and the words.
  static double area(int a, int b, int c) => closes(a, b, c) ? sqrt(sixteenAreaSquared(a, b, c)) / 4 : 0;

  static bool isRight(int a, int b, int c) {
    final s = [a, b, c]..sort();
    return s[0] * s[0] + s[1] * s[1] == s[2] * s[2];
  }

  static bool isIsosceles(int a, int b, int c) => a == b || b == c || a == c;

  static bool allOdd(int a, int b, int c) => a.isOdd && b.isOdd && c.isOdd;

  /// Every triangle with sides a <= b <= c to [most], as (a, b, c).
  static List<(int, int, int)> get triangles => [
        for (var a = 1; a <= most; a++)
          for (var b = a; b <= most; b++)
            for (var c = b; c <= most; c++)
              if (closes(a, b, c)) (a, b, c),
      ];

  /// The sides sorted, so any order of the dials names one triangle.
  static (int, int, int) sorted(int a, int b, int c) {
    final s = [a, b, c]..sort();
    return (s[0], s[1], s[2]);
  }
}
