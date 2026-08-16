import 'dart:io';

import 'package:cornerwick/square/frac.dart';
import 'package:cornerwick/square/levels.dart';
import 'package:cornerwick/square/play.dart';
import 'package:cornerwick/square/rules.dart';

/// Squares every four of pegs two ways, counts what Van Aubel promises,
/// and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_squares.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  check(Rules.side == 5 && Rules.pegs.length == 25, 'the board');
  // The centre of a square on a side sits half a side out from the middle.
  check(Rules.centre((1, 1), (3, 1)) == (4, 0) && Rules.centre((3, 1), (3, 3)) == (8, 4) && Rules.centre((0, 0), (0, 1)) == (1, 1), 'the centres');
  check(Rules.square((1, 1), (3, 1)).toString() == '[(2, 2), (6, 2), (6, -2), (2, -2)]', 'the square on a side: ${Rules.square((1, 1), (3, 1))}');
  var fours = 0, clear = 0, whole = 0, square = 0, para = 0, paraNotSquare = 0, folded = 0, meeting = 0, fives = 0, sameAll = 0, rightAll = 0, turnedAll = 0, squareNotPara = 0;
  final lengths = <Frac, int>{};
  Rules.fours((f) {
    fours++;
    final same = Rules.sameLength(f), right = Rules.atRightAngles(f), turned = Rules.turnedIsTheOther(f);
    if (same) sameAll++;
    if (right) rightAll++;
    if (turned) turnedAll++;
    check(same && right && turned, 'the joins on $f: same $same, right $right, turned $turned');
    // The crossing, when there is one, lies on both joins.
    final x = Rules.crossing(f);
    if (x != null) {
      final c = Rules.centres(f);
      final (u, v) = Rules.joins(f);
      // (x - p/2) is along u: cross product nought; the same for q and v.
      final px = x.$1 * Frac.of(2) - Frac.of(c[0].$1), py = x.$2 * Frac.of(2) - Frac.of(c[0].$2);
      final qx = x.$1 * Frac.of(2) - Frac.of(c[1].$1), qy = x.$2 * Frac.of(2) - Frac.of(c[1].$2);
      check(px * Frac.of(u.$2) - py * Frac.of(u.$1) == Frac.zero && qx * Frac.of(v.$2) - qy * Frac.of(v.$1) == Frac.zero, 'the crossing of $f is off a join');
    }
    final pa = Rules.parallelogram(f), sq = Rules.centresMakeSquare(f);
    if (pa) para++;
    if (sq) square++;
    if (sq && !pa) squareNotPara++;
    if (pa && !sq) {
      paraNotSquare++;
      final c = Rules.centres(f);
      if (c.every((p) => p == c[0])) folded++;
    }
    if (Rules.threeInLine(f)) return;
    clear++;
    if (Rules.centresWhole(f)) whole++;
    if (x != null && x.$1.isWhole && x.$2.isWhole) meeting++;
    final (l, _) = Rules.lengthsSquared(f);
    if (l == Frac.of(25)) fives++;
    lengths[l] = (lengths[l] ?? 0) + 1;
  });
  check(fours == 303600 && clear == 227952, 'fours $fours, with no three in a line $clear');
  check(sameAll == fours && rightAll == fours && turnedAll == fours, 'same $sameAll, right $rightAll, turned $turnedAll of $fours');
  check(whole == 18528 && meeting == 31480 && fives == 2960, 'whole $whole, meeting $meeting, fives $fives');
  check(para == 5712 && square == 5512 && squareNotPara == 0 && paraNotSquare == 200 && folded == 200, 'parallelograms $para, squares of centres $square, square not parallelogram $squareNotPara, parallelogram not square $paraNotSquare, folded $folded');
  var clearSquare = 0;
  Rules.fours((f) {
    if (!Rules.threeInLine(f) && Rules.centresMakeSquare(f)) clearSquare++;
  });
  check(clearSquare == 5192, 'squares of centres with no three in a line $clearSquare');
  final sortedLengths = lengths.keys.toList()..sort();
  final commonest = lengths.entries.reduce((a, b) => a.value >= b.value ? a : b);
  check(lengths.length == 42 && commonest.key == Frac.of(5, 2) && commonest.value == 24320 && sortedLengths.first == Frac.zero && sortedLengths.last == Frac.of(64) && lengths[Frac.zero] == 3832, 'the lengths: ${lengths.length}, commonest ${commonest.key} on ${commonest.value}, from ${sortedLengths.first} to ${sortedLengths.last}, nought on ${lengths[Frac.zero]}');
  final named = [(1, 1), (3, 1), (3, 3), (1, 3)];
  check(Rules.centres(named).toString() == '[(4, 0), (8, 4), (4, 8), (0, 4)]' && Rules.centresWhole(named) && Rules.centresMakeSquare(named) && Rules.lengthsSquared(named).$1 == Frac.of(16) && Rules.crossing(named) == (Frac.of(2), Frac.of(2)), 'the pegs (1, 1), (3, 1), (3, 3), (1, 3)');
  final para1 = [(0, 0), (3, 1), (4, 4), (1, 3)];
  check(Rules.parallelogram(para1) && Rules.centresMakeSquare(para1) && Rules.lengthsSquared(para1).$1 == Frac.of(36) && Rules.crossing(para1) == (Frac.of(2), Frac.of(2)) && Rules.tellLength(Frac.of(36)) == '6', 'the pegs (0, 0), (3, 1), (4, 4), (1, 3)');
  check(Rules.tellLength(Frac.of(25)) == '5' && Rules.tellLength(Frac.of(50)) == 'root 50' && Rules.tellLength(Frac.of(5, 2)) == 'root 5/2', 'the lengths told');
  final clockwise = [(0, 0), (0, 1), (1, 1), (1, 0)];
  check(Rules.centres(clockwise).every((c) => c == (1, 1)), 'the square walked the wrong way');

  // The asks.
  for (final level in Levels.all) {
    var ways = 0;
    Rules.fours((f) {
      if (level.meets(f)) ways++;
    });
    check(ways == level.ways, '${level.name}: ${level.ways} said, $ways swept');
    final aim = level.aim;
    check((aim == null) == !level.winnable, '${level.name}: aim $aim');
    if (aim != null) check(level.meets(aim), '${level.name}: the aim misses');
    final open = Play.of(level);
    check(!open.isOver, '${level.name}: opens over');
    if (aim != null) {
      var play = open;
      var steps = 0;
      while (!play.isDone && steps < 12) {
        final (peg, _) = play.next!;
        play = play.tap(peg);
        steps++;
      }
      check(play.isDone && play.moves == 4, '${level.name}: the pointer never lands, or takes ${play.moves} taps');
    }
  }
  check(Levels.at(1).aim.toString() == '[(0, 0), (1, 0), (1, 1), (0, 1)]' && Levels.at(3).aim.toString() == '[(0, 0), (1, 0), (3, 1), (1, 4)]', 'the aims');
  final dead = Play.of(Levels.at(4)).tap((0, 0)).tap((3, 1)).tap((4, 4)).tap((1, 3)).tap((1, 3)).tap((2, 3)).tap((2, 3)).tap((0, 4));
  check(dead.tried == 3 && dead.gaveUp, 'the skew cross does not admit it after three fours');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every ordered four of pegs on the five-by-five board taken, ${commas(fours)}, the four centres of the squares on its sides found and the two joins of opposite centres read for length and angle, and the first join turned a right angle worked out from the four pegs alone and found to be the second join, on all ${commas(fours)}: the two joins are of one length and at right angles on every four, and their crossing lies on both wherever they cross; ${commas(clear)} fours have no three pegs in a line, and of those ${commas(whole)} put all four centres on peg places, ${commas(clearSquare)} make a square of the centres, every one a parallelogram and every parallelogram among them making one, ${commas(meeting)} cross the joins on a peg place and ${commas(fives)} have joins five long, the joins taking ${lengths.length} lengths in all, root 5/2 the commonest on ${commas(commonest.value)}, from nought, on 3,832 fours whose opposite centres fall together, up to eight on the boardwide square; the pegs (1, 1), (3, 1), (3, 3), (1, 3) put the centres at (2, 0), (4, 2), (2, 4) and (0, 2), joins four long crossing at (2, 2), and a square walked clockwise drops all four centres in one place, 200 fours\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(clear)} fours land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${commas(clear)}, and the turned join said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
