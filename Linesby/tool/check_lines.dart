import 'dart:io';

import 'package:linesby/line/frac.dart';
import 'package:linesby/line/levels.dart';
import 'package:linesby/line/play.dart';
import 'package:linesby/line/rules.dart';

/// Sweeps every triangle of the field, works its three centres exactly
/// two ways, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_lines.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  final triangles = Rules.triangles;
  check(triangles.length == 17600, 'triangles ${triangles.length}');
  check(Rules.pegs.length == 49, 'pegs ${Rules.pegs.length}');
  var lines = 0;
  final all = Rules.pegs;
  for (var i = 0; i < all.length; i++) {
    for (var j = i + 1; j < all.length; j++) {
      for (var k = j + 1; k < all.length; k++) {
        if (Rules.inLine(all[i], all[j], all[k])) lines++;
      }
    }
  }
  check(lines == 824 && lines + triangles.length == 18424, 'lines of three $lines');

  // The two voices on every triangle, and the line through the centres.
  var right = 0, obtuse = 0, acute = 0, wholeG = 0, wholeO = 0, wholeH = 0, equilateral = 0, nearest = 0;
  final half = Frac.of(1, 2);
  for (final (a, b, c) in triangles) {
    final g = Rules.centroid(a, b, c), o = Rules.circumcentre(a, b, c), h = Rules.orthocentre(a, b, c);
    check(h == Rules.orthocentreByO(a, b, c), 'orthocentre of $a $b $c: altitudes ${Rules.told(h)}, A + B + C - 2O ${Rules.told(Rules.orthocentreByO(a, b, c))}');
    check(Rules.inLineF(g, o, h), 'centres of $a $b $c not in a line');
    check(Rules.twiceAsFar(g, o, h), 'centres of $a $b $c: HG not twice GO');
    // The circumcentre is as far from each corner; the altitudes stand
    // square to the sides.
    final da = Rules.dist2F(o, Rules.whole(a));
    check(da == Rules.dist2F(o, Rules.whole(b)) && da == Rules.dist2F(o, Rules.whole(c)), 'circumcentre of $a $b $c not equidistant');
    Frac perp(Centre p, Peg from, Peg u, Peg v) => (p.$1 - Frac.of(from.$1)) * Frac.of(v.$1 - u.$1) + (p.$2 - Frac.of(from.$2)) * Frac.of(v.$2 - u.$2);
    check(perp(h, a, b, c) == Frac.zero && perp(h, b, c, a) == Frac.zero && perp(h, c, a, b) == Frac.zero, 'orthocentre of $a $b $c off an altitude');
    // The nine-point centre halfway from O to H is as far from the three
    // midpoints.
    final n = ((o.$1 + h.$1) * half, (o.$2 + h.$2) * half);
    check(n == Rules.ninePoint(a, b, c), 'nine-point centre of $a $b $c');
    Centre mid(Peg p, Peg q) => (Frac.of(p.$1 + q.$1) * half, Frac.of(p.$2 + q.$2) * half);
    final dn = Rules.dist2F(n, mid(a, b));
    check(dn == Rules.dist2F(n, mid(b, c)) && dn == Rules.dist2F(n, mid(c, a)), 'nine-point centre of $a $b $c not equidistant from the midpoints');
    final kind = Rules.kind(a, b, c);
    final where = Rules.where(o, a, b, c);
    check(kind == 'acute' ? where == 'inside' : kind == 'right' ? where == 'on the edge' : where == 'outside', 'circumcentre of $a $b $c $where in a $kind triangle');
    if (kind == 'right') {
      right++;
      final corner = Rules.rightAt(a, b, c)!;
      check(h == Rules.whole(corner), 'right triangle $a $b $c: H ${Rules.told(h)} not on the corner $corner');
      final others = [a, b, c].where((p) => p != corner).toList();
      check(o == mid(others[0], others[1]), 'right triangle $a $b $c: O not halfway along the hypotenuse');
    } else if (kind == 'obtuse') {
      obtuse++;
    } else {
      acute++;
    }
    if (Rules.isWhole(g)) wholeG++;
    if (Rules.isWhole(o)) wholeO++;
    if (Rules.isWhole(h)) wholeH++;
    final s = Rules.sides(a, b, c);
    if (s[0] == s[1] && s[1] == s[2]) equilateral++;
    if (g == o || o == h || g == h) check(false, 'two centres of $a $b $c meet');
    final spread = Rules.spread(a, b, c);
    check(spread.$1 * Rules.nearest.$2 >= Rules.nearest.$1 * spread.$2, 'nearer than the nearest: $a $b $c $spread');
    if (spread == Rules.nearest) nearest++;
  }
  check(right == 2960 && obtuse == 10760 && acute == 3880, 'kinds $right $obtuse $acute');
  check(wholeG == 1716 && wholeO == 2428 && wholeH == 9876, 'whole centres $wholeG $wholeO $wholeH');
  check(equilateral == 0, 'equilateral $equilateral');
  check(nearest == 44, 'nearest $nearest');
  check(Rules.spread((0, 0), (4, 1), (1, 4)) == (18, 17), 'the nearest example');
  check(Rules.told(Rules.centroid((0, 0), (4, 1), (1, 4))) == '(5/3, 5/3)' && Rules.told(Rules.circumcentre((0, 0), (4, 1), (1, 4))) == '(17/10, 17/10)' && Rules.told(Rules.orthocentre((0, 0), (4, 1), (1, 4))) == '(8/5, 8/5)', 'the nearest example\'s centres');

  // The asks.
  final counts = <String, int>{};
  for (final level in Levels.all) {
    var n = 0;
    for (final (a, b, c) in triangles) {
      if (level.meets(a, b, c)) n++;
    }
    counts[level.kind] = n;
    check(n == level.ways, '${level.name}: ${level.ways} said, $n swept');
    final aim = level.aim;
    check((aim == null) == !level.winnable, '${level.name}: aim $aim');
    if (aim != null) check(level.meets(aim.$1, aim.$2, aim.$3), '${level.name}: the aim misses');
    final open = Play.of(level);
    check(!open.isOver, '${level.name}: opens over');
    if (aim != null) {
      var play = open;
      var steps = 0;
      while (!play.isDone && steps < 12) {
        final (peg, to) = play.next!;
        play = play.tap(play.pegs[peg]).tap(to);
        steps++;
      }
      check(play.isDone && play.moves <= 3, '${level.name}: the pointer never lands, or takes ${play.moves} moves');
    }
  }
  check(Levels.at(0).aim == ((0, 0), (1, 0), (0, 1)), 'the right angle\'s aim');
  check(Levels.at(1).aim == ((0, 0), (4, 0), (1, 3)), 'the level line\'s aim');
  check(Levels.at(2).aim == ((0, 0), (1, 0), (4, 1)), 'the far centre\'s aim');
  check(Levels.at(3).aim == ((0, 0), (6, 0), (3, 3)), 'the whole three\'s aim');

  // Named facts.
  var levelRight = 0, levelIso = 0, offObtuse = 0, wholeRight = 0;
  Frac? far;
  (Peg, Peg, Peg)? farAt;
  final middle = (Frac.of(3), Frac.of(3));
  for (final (a, b, c) in triangles) {
    final kind = Rules.kind(a, b, c);
    if (Levels.at(1).meets(a, b, c)) {
      if (kind == 'right') levelRight++;
      final s = Rules.sides(a, b, c);
      if (s[0] == s[1] || s[1] == s[2] || s[0] == s[2]) levelIso++;
    }
    if (Levels.at(2).meets(a, b, c) && kind == 'obtuse') offObtuse++;
    if (Levels.at(3).meets(a, b, c) && kind == 'right') wholeRight++;
    final d = Rules.dist2F(Rules.circumcentre(a, b, c), middle);
    if (far == null || d.compareTo(far) > 0) {
      far = d;
      farAt = (a, b, c);
    }
  }
  check(levelRight == 134 && levelIso == 378, 'level line: right $levelRight, isosceles $levelIso');
  check(offObtuse == counts['off'], 'far centres obtuse: $offObtuse of ${counts['off']}');
  check(wholeRight == counts['whole'], 'whole three right: $wholeRight of ${counts['whole']}');
  check(farAt == ((0, 0), (1, 1), (6, 5)) && Rules.told(Rules.circumcentre((0, 0), (1, 1), (6, 5))) == '(51/2, -49/2)' && Rules.told(Rules.orthocentre((0, 0), (1, 1), (6, 5))) == '(-44, 55)', 'the farthest centre: $farAt');
  check(Rules.told(Rules.circumcentre((0, 0), (1, 0), (4, 1))) == '(1/2, 13/2)', 'the far centre\'s first');
  check(Rules.told(Rules.centroid((0, 0), (4, 0), (1, 3))) == '(5/3, 1)' && Rules.told(Rules.circumcentre((0, 0), (4, 0), (1, 3))) == '(2, 1)' && Rules.told(Rules.orthocentre((0, 0), (4, 0), (1, 3))) == '(1, 1)', 'the level line\'s first');
  check(Rules.told(Rules.centroid((0, 0), (6, 0), (3, 3))) == '(3, 1)' && Rules.told(Rules.circumcentre((0, 0), (6, 0), (3, 3))) == '(3, 0)' && Rules.told(Rules.orthocentre((0, 0), (6, 0), (3, 3))) == '(3, 3)', 'the whole three\'s first');
  check(Rules.told(Rules.centroid((0, 0), (6, 0), (0, 6))) == '(2, 2)' && Rules.told(Rules.circumcentre((0, 0), (6, 0), (0, 6))) == '(3, 3)' && Rules.told(Rules.orthocentre((0, 0), (6, 0), (0, 6))) == '(0, 0)', 'the right isosceles');
  check(Rules.told(Rules.centroid((0, 0), (1, 0), (0, 1))) == '(1/3, 1/3)' && Rules.told(Rules.circumcentre((0, 0), (1, 0), (0, 1))) == '(1/2, 1/2)' && Rules.told(Rules.orthocentre((0, 0), (1, 0), (0, 1))) == '(0, 0)', 'the three-peg corner');
  final open = Play.of(Levels.at(0));
  check(open.kind == 'acute' && Rules.told(open.centroid) == '(8/3, 7/3)' && Rules.told(open.circumcentre) == '(63/22, 45/22)' && Rules.told(open.orthocentre) == '(25/11, 32/11)', 'the opening');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every triangle of the seven-by-seven field swept, ${commas(triangles.length)} of them, three pegs not in a line, with the 824 lines of three set aside; on every one the centroid, the circumcentre from the equal distances and the orthocentre from the altitudes were worked as exact fractions, and the orthocentre came out again as A + B + C less twice the circumcentre, the three centres lay in a line with the orthocentre twice as far from the centroid as the circumcentre, and the nine-point centre halfway from O to H stood as far from the three midpoints; ${commas(right)} triangles are right-angled with the orthocentre on the corner and the circumcentre halfway along the side across, ${commas(obtuse)} obtuse with the circumcentre outside and ${commas(acute)} acute with it inside; the centroid lands on a peg for ${commas(wholeG)}, the circumcentre for ${commas(wholeO)} and the orthocentre for ${commas(wholeH)}; no triangle is equilateral, and the nearest, sides squared 17, 17 and 18, comes $nearest times, its centres still apart\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(triangles.length)} triangles land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${commas(triangles.length)}, and the tangent of sixty degrees said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
