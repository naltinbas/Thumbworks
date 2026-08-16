import 'dart:io';

import 'package:chordwell/chord/frac.dart';
import 'package:chordwell/chord/levels.dart';
import 'package:chordwell/chord/play.dart';
import 'package:chordwell/chord/rules.dart';

/// Works every crossing of the wheel's chords exactly, sets the two
/// products against the power of the crossing, and refuses the bake on
/// any disagreement.
///
/// Run with: dart run tool/check_chords.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  // The wheel.
  check(Rules.pegs.length == 12 && Rules.pegs.every(Rules.onWheel) && Rules.pegs.toSet().length == 12, 'the pegs');
  var whole = 0;
  for (var x = -5; x <= 5; x++) {
    for (var y = -5; y <= 5; y++) {
      if (x * x + y * y == 25) whole++;
    }
  }
  check(whole == 12, 'whole points on the circle: $whole');
  final chords = Rules.chords;
  check(chords.length == 66, 'chords ${chords.length}');
  final crossings = Rules.crossings;
  check(crossings.length == 495, 'crossings ${crossings.length}');
  // Every four pegs give exactly one crossing pair.
  var fours = 0;
  final seenFours = <String>{};
  for (var i = 0; i < 12; i++) {
    for (var j = i + 1; j < 12; j++) {
      for (var k = j + 1; k < 12; k++) {
        for (var l = k + 1; l < 12; l++) {
          fours++;
          var ways = 0;
          for (final (a, b, c, d) in [(i, j, k, l), (i, k, j, l), (i, l, j, k)]) {
            if (Rules.crossing(Rules.pegs[a], Rules.pegs[b], Rules.pegs[c], Rules.pegs[d]) != null) ways++;
          }
          check(ways == 1, 'four $i $j $k $l crosses $ways ways');
        }
      }
    }
  }
  for (final ((a, b), (c, d)) in crossings) {
    final key = ([a, b, c, d]..sort()).join(',');
    check(seenFours.add(key), 'four $key crosses twice');
  }
  check(fours == 495 && seenFours.length == 495, 'fours $fours');

  // The two voices on every crossing, and the named counts.
  var middle = 0, square = 0, squareOff = 0, halved = 0, halvedBoth = 0, lattice = 0, perpendicular = 0;
  final byPower = <Frac, int>{};
  final twentyAt = <String, int>{};
  for (final ((a, b), (c, d)) in crossings) {
    final A = Rules.pegs[a], B = Rules.pegs[b], C = Rules.pegs[c], D = Rules.pegs[d];
    final p = Rules.crossing(A, B, C, D)!;
    final one = Rules.product(p, A, B), two = Rules.product(p, C, D), power = Rules.power(p);
    check(one == two, 'products at $A-$B x $C-$D: $one and $two');
    check(one == power, 'product $one against the power $power at ${Rules.tellPoint(p)}');
    check(power.compareTo(Frac.zero) > 0 && power.compareTo(Frac.of(25)) <= 0, 'power out of range');
    // The crossing lies on both chords, strictly between the ends.
    check(Rules.piece2(p, A).compareTo(Frac.zero) > 0 && Rules.piece2(p, B).compareTo(Frac.zero) > 0, 'crossing at an end');
    // The pieces of a chord multiply as lengths: the squares multiply
    // to the product squared.
    check(Rules.piece2(p, A) * Rules.piece2(p, B) == one * one && Rules.piece2(p, C) * Rules.piece2(p, D) == two * two, 'pieces of $A-$B x $C-$D');
    if (Rules.isMiddle(p)) {
      middle++;
      check(Rules.isDiameter(A, B) && Rules.isDiameter(C, D) && power == Frac.of(25), 'middle crossing not two diameters');
    }
    if (Rules.square(A, B, C, D)) {
      square++;
      if (!Rules.isMiddle(p)) squareOff++;
    }
    final h1 = Rules.halves(p, A, B), h2 = Rules.halves(p, C, D);
    if (h1 || h2) halved++;
    if (h1 && h2) {
      halvedBoth++;
      check(Rules.isMiddle(p), 'both halved away from the middle');
    }
    if (!Rules.isMiddle(p)) {
      for (final (X, Y) in [(A, B), (C, D)]) {
        if (Rules.halves(p, X, Y)) {
          check(!Rules.isDiameter(X, Y), 'a diameter halved away from the middle');
          final dot = p.$1 * Frac.of(Y.$1 - X.$1) + p.$2 * Frac.of(Y.$2 - X.$2);
          if (dot == Frac.zero) perpendicular++;
        }
      }
    }
    if (p.$1.isWhole && p.$2.isWhole) lattice++;
    byPower[power] = (byPower[power] ?? 0) + 1;
    if (power == Frac.of(20)) twentyAt[Rules.tellPoint(p)] = (twentyAt[Rules.tellPoint(p)] ?? 0) + 1;
  }
  check(middle == 15 && square == 43 && squareOff == 40 && halved == 79 && halvedBoth == 15 && lattice == 151, 'counts: middle $middle, square $square ($squareOff off), halved $halved ($halvedBoth both), lattice $lattice');
  check(perpendicular == 64 && halved - halvedBoth == 64, 'perpendicular $perpendicular of ${halved - halvedBoth}');
  check(byPower[Frac.of(25)] == 15 && byPower[Frac.of(24)] == 12 && byPower[Frac.of(20)] == 48 && byPower[Frac.of(16)] == 4 && byPower[Frac.of(9)] == 4 && byPower[Frac.of(7)] == 4 && byPower[Frac.of(5)] == 8, 'by power: 25 ${byPower[Frac.of(25)]}, 24 ${byPower[Frac.of(24)]}, 20 ${byPower[Frac.of(20)]}, 16 ${byPower[Frac.of(16)]}, 9 ${byPower[Frac.of(9)]}, 7 ${byPower[Frac.of(7)]}, 5 ${byPower[Frac.of(5)]}');
  final commonest = byPower.entries.reduce((a, b) => a.value >= b.value ? a : b);
  check(commonest.key == Frac.of(20) && commonest.value == 48, 'commonest power ${commonest.key} ${commonest.value}');
  check(twentyAt.length == 8 && twentyAt.values.every((v) => v == 6) && twentyAt.keys.every((k) => ['(2, 1)', '(1, 2)', '(2, -1)', '(1, -2)', '(-2, 1)', '(-1, 2)', '(-2, -1)', '(-1, -2)'].contains(k)), 'twenty at $twentyAt');
  check(byPower.length == 44, 'different powers ${byPower.length}');
  final nineAt = <String>{};
  for (final ((a, b), (c, d)) in crossings) {
    final p = Rules.crossing(Rules.pegs[a], Rules.pegs[b], Rules.pegs[c], Rules.pegs[d])!;
    if (Rules.power(p) == Frac.of(9)) nineAt.add(Rules.tellPoint(p));
  }
  check(nineAt.length == 4 && nineAt.containsAll(['(0, 4)', '(0, -4)', '(4, 0)', '(-4, 0)']), 'nine at $nineAt');

  // Named crossings.
  final mark = Rules.crossing((3, 4), (3, -4), (5, 0), (-5, 0))!;
  check(Rules.tellPoint(mark) == '(3, 0)' && Rules.product(mark, (3, 4), (3, -4)) == Frac.of(16) && Rules.product(mark, (5, 0), (-5, 0)) == Frac.of(16), 'the mark');
  check(Rules.tellLength(Rules.piece2(mark, (3, 4))) == '4' && Rules.tellLength(Rules.piece2(mark, (5, 0))) == '2' && Rules.tellLength(Rules.piece2(mark, (-5, 0))) == '8', 'the mark\'s pieces');
  final nine = Rules.crossing((0, 5), (0, -5), (3, 4), (-3, 4))!;
  check(Rules.tellPoint(nine) == '(0, 4)' && Rules.tellLength(Rules.piece2(nine, (0, 5))) == '1' && Rules.tellLength(Rules.piece2(nine, (0, -5))) == '9' && Rules.tellLength(Rules.piece2(nine, (3, 4))) == '3', 'the nine\'s first');
  final twenty = Rules.crossing((0, 5), (4, -3), (3, 4), (0, -5))!;
  check(Rules.tellPoint(twenty) == '(2, 1)' && Rules.tellLength(Rules.piece2(twenty, (0, 5))) == 'root 20' && Rules.tellLength(Rules.piece2(twenty, (4, -3))) == 'root 20' && Rules.tellLength(Rules.piece2(twenty, (3, 4))) == 'root 10' && Rules.tellLength(Rules.piece2(twenty, (0, -5))) == 'root 40', 'the twenty\'s first');
  final halvedFirst = Rules.crossing((0, 5), (4, 3), (3, 4), (-3, 4))!;
  check(Rules.tellPoint(halvedFirst) == '(2, 4)' && Rules.halves(halvedFirst, (0, 5), (4, 3)) && Rules.tellLength(Rules.piece2(halvedFirst, (0, 5))) == 'root 5' && Rules.tellLength(Rules.piece2(halvedFirst, (3, 4))) == '1' && Rules.tellLength(Rules.piece2(halvedFirst, (-3, 4))) == '5', 'the halved\'s first');
  check(Rules.crossing((0, 5), (3, 4), (3, 4), (5, 0)) == null && Rules.crossing((0, 5), (3, 4), (4, 3), (5, 0)) == null, 'no crossing when a peg is shared or the chords miss');
  var diameters = 0;
  for (final (a, b) in chords) {
    if (Rules.isDiameter(Rules.pegs[a], Rules.pegs[b])) diameters++;
  }
  check(diameters == 6, 'diameters $diameters');

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (final ((a, b), (c, d)) in crossings) {
      if (level.meets(Rules.pegs[a], Rules.pegs[b], Rules.pegs[c], Rules.pegs[d])) n++;
    }
    check(n == level.ways, '${level.name}: ${level.ways} said, $n swept');
    final aim = level.aim;
    check((aim == null) == !level.winnable, '${level.name}: aim $aim');
    if (aim != null) check(level.meets(Rules.pegs[aim[0]], Rules.pegs[aim[1]], Rules.pegs[aim[2]], Rules.pegs[aim[3]]), '${level.name}: the aim misses');
    final open = Play.of(level);
    check(!open.isOver, '${level.name}: opens over');
    if (aim != null) {
      var play = open;
      var steps = 0;
      while (!play.isDone && steps < 8) {
        final (peg, _) = play.next!;
        play = play.tap(peg);
        steps++;
      }
      check(play.isDone && play.moves == 4, '${level.name}: the pointer never lands, or takes ${play.moves} taps');
    }
  }
  check(Levels.at(0).aim!.join(',') == '0,6,1,7' && Levels.at(1).aim!.join(',') == '0,6,1,11' && Levels.at(2).aim!.join(',') == '0,4,1,6' && Levels.at(3).aim!.join(',') == '0,2,1,11', 'the aims');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('the twelve whole points on the circle of radius five taken as pegs, 66 chords between them, and every four pegs found to give exactly one pair of chords that cross inside, 495 crossings; on every crossing the point was worked exactly and the pieces of each chord multiplied, the two products agreeing with each other and with 25 less the crossing\'s distance from the middle squared on all 495; 15 crossings fall at the middle, two diameters each with every piece 5, 43 cross at right angles, 40 of them away from the middle, 79 cut a chord in half, 64 of them away from the middle with the middle\'s line to the crossing square to the halved chord every time, and 151 fall on whole points; the products take 44 different values, 20 the commonest on 48 crossings, all at the eight points root five from the middle, and 9 comes four times only, at (0, 4), (0, -4), (4, 0) and (-4, 0)\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${crossings.length} crossings land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${crossings.length}, and the two triangles said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
