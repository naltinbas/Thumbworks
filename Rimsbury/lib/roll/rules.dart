import 'dart:math';

/// The arithmetic of the roll: a hoop and a roller, whole units across
/// their radii, and the roller rolled once round the hoop, outside or
/// inside, without slipping. The turns come two ways: the formula, an
/// exact fraction, and the roll itself, pivoted about the point of
/// contact a hair at a time and added up.
class Rules {
  /// The dials run from one to this.
  static const most = 6;

  /// How many settings there are: hoop by roller by the two sides.
  static const settings = most * most * 2;

  /// Whether the roller fits: anywhere outside, and inside only when it
  /// is smaller than the hoop.
  static bool fits(int hoop, int coin, bool inside) => !inside || coin < hoop;

  /// The turns a trip makes, by the formula, in lowest terms: hoop plus
  /// roller over roller outside, hoop less roller over roller inside;
  /// null when the roller does not fit.
  static (int, int)? turns(int hoop, int coin, bool inside) {
    if (!fits(hoop, coin, inside)) return null;
    final num = inside ? hoop - coin : hoop + coin;
    final g = num.gcd(coin);
    return (num ~/ g, coin ~/ g);
  }

  /// The rim's share of the turns, hoop over roller, in lowest terms.
  static (int, int) rim(int hoop, int coin) {
    final g = hoop.gcd(coin);
    return (hoop ~/ g, coin ~/ g);
  }

  /// The turns a trip makes, rolled: the roller pivots about its point
  /// of contact a small angle at a time, which is what rolling without
  /// slipping is, its centre set back onto its ring after each pivot,
  /// until the centre has gone once round; the pivots add up to the
  /// turns, outside counted up and inside down. NaN when the roller
  /// does not fit.
  static double turnsRolled(int hoop, int coin, bool inside, {int steps = 36000}) {
    if (!fits(hoop, coin, inside)) return double.nan;
    final ring = (inside ? hoop - coin : hoop + coin).toDouble();
    final delta = 2 * pi * ring / coin / steps;
    final spin = inside ? -delta : delta;
    var theta = 0.0, gone = 0.0, turned = 0.0;
    while (gone < 2 * pi) {
      final cx = ring * cos(theta), cy = ring * sin(theta);
      final px = hoop * cos(theta), py = hoop * sin(theta);
      final ax = cx - px, ay = cy - py;
      final nx = px + ax * cos(spin) - ay * sin(spin), ny = py + ax * sin(spin) + ay * cos(spin);
      var next = atan2(ny, nx);
      var step = next - theta;
      if (step < -pi) step += 2 * pi;
      if (step > pi) step -= 2 * pi;
      if (gone + step >= 2 * pi) {
        // The last pivot, cut to land the centre exactly where it began.
        turned += spin * (2 * pi - gone) / step;
        gone = 2 * pi;
        break;
      }
      gone += step;
      theta = next;
      turned += spin;
    }
    return turned / (2 * pi);
  }

  /// Where the roller's centre is when it has gone [theta] round the
  /// hoop, and where its mark is, the mark starting at the point of
  /// contact: (centre x, centre y, mark x, mark y), in units, the trip
  /// starting on the right and going anticlockwise.
  static (double, double, double, double) place(int hoop, int coin, bool inside, double theta) {
    final ring = (inside ? hoop - coin : hoop + coin).toDouble();
    final cx = ring * cos(theta), cy = ring * sin(theta);
    final heading = inside ? -(hoop - coin) * theta / coin : pi + (hoop + coin) * theta / coin;
    return (cx, cy, cx + coin * cos(heading), cy + coin * sin(heading));
  }

  /// The setting, told: 'a hoop of three and a roller of one'.
  static String told(int hoop, int coin) => 'a hoop of ${count(hoop)} and a roller of ${count(coin)}';

  /// A fraction, told: '3/2', or '2'.
  static String fraction((int, int) f) => f.$2 == 1 ? '${f.$1}' : '${f.$1}/${f.$2}';

  /// Turns, told: 'two turns', 'one turn', 'half a turn', 'three halves
  /// of a turn', 'seven sixths of a turn'.
  static String turnsTold((int, int) f) {
    if (f.$2 == 1) return '${count(f.$1)} turn${f.$1 == 1 ? '' : 's'}';
    if (f.$1 == 1) return f.$2 == 2 ? 'half a turn' : 'a ${_part(f.$2)} of a turn';
    return '${count(f.$1)} ${_parts(f.$2)} of a turn';
  }

  static String _part(int den) => switch (den) {
        3 => 'third',
        4 => 'quarter',
        5 => 'fifth',
        6 => 'sixth',
        _ => '${den}th',
      };

  static String _parts(int den) => switch (den) {
        2 => 'halves',
        3 => 'thirds',
        4 => 'quarters',
        5 => 'fifths',
        6 => 'sixths',
        _ => '${den}ths',
      };

  static const _words = ['no', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve'];

  static String count(int n) => n >= 0 && n < _words.length ? _words[n] : '$n';
}
