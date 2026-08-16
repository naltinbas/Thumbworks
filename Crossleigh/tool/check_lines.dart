import 'dart:io';

import 'package:crossleigh/cut/frac.dart';
import 'package:crossleigh/cut/levels.dart';
import 'package:crossleigh/cut/play.dart';
import 'package:crossleigh/cut/rules.dart';

/// Cuts the triangle by every line through two pegs of the field, reads
/// the ratios two ways, and refuses the bake on any disagreement.
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

  final pegs = Rules.pegs;
  check(pegs.length == 169, 'pegs ${pegs.length}');
  final everyLine = <(int, int, int)>{};
  var throughFourEight = 0;
  for (var i = 0; i < pegs.length; i++) {
    for (var j = i + 1; j < pegs.length; j++) {
      if (everyLine.add(Rules.lineOf(pegs[i], pegs[j])) && Rules.cross(pegs[i], pegs[j], (4, 8)) == 0) throughFourEight++;
    }
  }
  check(everyLine.length == 6460, 'lines through two pegs: ${everyLine.length}');
  final lines = Rules.lines;
  check(lines.length == 6140, 'lines crossing all three side-lines: ${lines.length}');
  check(throughFourEight == 78, 'lines through (4, 8): $throughFourEight');

  var two = 0, none = 0, whole = 0, wholeTwo = 0, middle = 0, middleWhole = 0, twice = 0;
  for (final (p, q) in lines) {
    final byCrossings = Rules.ratiosByCrossings(p, q), byAreas = Rules.ratiosByAreas(p, q);
    check(byCrossings == byAreas, 'ratios through $p $q: crossings $byCrossings, areas $byAreas');
    check(Rules.product(byCrossings) == Frac.of(-1), 'product through $p $q: ${Rules.product(byCrossings)}');
    final negatives = [byCrossings.$1, byCrossings.$2, byCrossings.$3].where((r) => r.compareTo(Frac.zero) < 0).length;
    check(negatives.isOdd, 'negatives through $p $q: $negatives');
    // The crossings lie on their side-lines and on the line itself.
    final (f, d, e) = Rules.crossings(p, q);
    check(f.$2 == Frac.zero && d.$1 + d.$2 == Frac.of(12) && e.$1 == Frac.zero, 'crossings off the side-lines through $p $q');
    for (final x in [f, d, e]) {
      final on = (Frac.of(q.$1 - p.$1)) * (x.$2 - Frac.of(p.$2)) - (Frac.of(q.$2 - p.$2)) * (x.$1 - Frac.of(p.$1));
      check(on == Frac.zero, 'a crossing off the line through $p $q');
    }
    final k = Rules.sidesInside(p, q);
    check(k == 0 || k == 2, 'sides inside through $p $q: $k');
    if (k == 2) two++;
    if (k == 0) none++;
    final isWhole = f.$1.isWhole && d.$1.isWhole && e.$2.isWhole;
    if (isWhole) {
      whole++;
      if (k == 2) wholeTwo++;
    }
    if (f.$1 == Frac.of(6)) {
      middle++;
      check(k == 2, 'a middle cut with the line outside');
      if (isWhole) middleWhole++;
    }
    if (byCrossings.$2 == Frac.of(2)) {
      twice++;
      check(d == (Frac.of(4), Frac.of(8)), 'twice, but not at (4, 8)');
      check(byCrossings.$1 * byCrossings.$3 == Frac.of(-1, 2), 'twice: AF:FB times CE:EA is not -1/2');
    }
  }
  check(two == 5572 && none == 568 && two + none == lines.length, 'two inside $two, none $none');
  check(whole == 152 && wholeTwo == 126 && middle == 90 && middleWhole == 16 && twice == 74, 'whole $whole ($wholeTwo two inside), middle $middle ($middleWhole whole), twice $twice');
  check(Rules.tellPoint(Rules.crossings((1, 0), (2, 1)).$2) == '(13/2, 11/2)' && Rules.ratiosByCrossings((1, 0), (2, 1)) == (Frac.of(1, 11), Frac.of(11, 13), Frac.of(-13)), 'the first two-inside line');
  check(Rules.ratiosByCrossings((6, 0), (0, 1)) == (Frac.one, Frac.of(-1, 11), Frac.of(11)) && Rules.ratiosByCrossings((6, 0), (0, 4)) == (Frac.one, Frac.of(-1, 2), Frac.of(2)), 'the middle cuts');
  check(Rules.tellPoint(Rules.crossings((1, 0), (0, 2)).$2) == '(-10, 22)' && Rules.ratiosByCrossings((1, 0), (0, 2)) == (Frac.of(1, 11), Frac.of(-11, 5), Frac.of(5)), 'the first whole line');
  check(Rules.crossings((2, 4), (6, 6)) == ((Frac.of(-6), Frac.zero), (Frac.of(6), Frac.of(6)), (Frac.zero, Frac.of(3))) && Rules.ratiosByCrossings((2, 4), (6, 6)) == (Frac.of(-1, 3), Frac.one, Frac.of(3)), 'the whole line through (2, 4) and (6, 6)');
  check(Rules.ratiosByCrossings((1, 0), (4, 8)) == (Frac.of(1, 11), Frac.of(2), Frac.of(-11, 2)) && Rules.ratiosByCrossings((4, 8), (0, 4)) == (Frac.of(-1, 4), Frac.of(2), Frac.of(2)), 'the twice lines');
  check(!Rules.crossesAll((0, 0), (1, 1)) && !Rules.crossesAll((1, 2), (5, 2)) && !Rules.crossesAll((3, 3), (3, 7)) && !Rules.crossesAll((2, 5), (5, 2)) && Rules.crossesAll((1, 2), (3, 4)), 'the excluded lines');

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (final (p, q) in lines) {
      if (level.meets(p, q)) n++;
    }
    check(n == level.ways, '${level.name}: ${level.ways} said, $n swept');
    final aim = level.aim;
    check((aim == null) == !level.winnable, '${level.name}: aim $aim');
    if (aim != null) check(level.meets(aim.$1, aim.$2), '${level.name}: the aim misses');
    final open = Play.of(level);
    check(!open.isOver, '${level.name}: opens over');
    if (aim != null) {
      var play = open;
      var steps = 0;
      while (!play.isDone && steps < 6) {
        final (peg, _) = play.next!;
        play = play.tap(peg);
        steps++;
      }
      check(play.isDone && play.moves == 2, '${level.name}: the pointer never lands, or takes ${play.moves} taps');
    }
  }
  check(Levels.at(0).aim == ((1, 0), (2, 1)) && Levels.at(1).aim == ((6, 0), (0, 1)) && Levels.at(2).aim == ((1, 0), (0, 2)) && Levels.at(3).aim == ((1, 0), (4, 8)), 'the aims');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every line through two pegs of the thirteen-by-thirteen field taken, ${commas(everyLine.length)} lines, and the ${commas(lines.length)} that cross all three side-lines of the triangle A (0, 0), B (12, 0), C (0, 12), neither parallel to a side nor through a corner, cut it exactly, the three crossings found on their side-lines and on the line, and the ratios AF:FB, BD:DC and CE:EA read off the crossings and again off the corners\' distances from the line, the two agreeing on all ${commas(lines.length)}, the product -1 on every one with an odd count of the ratios negative; ${commas(two)} lines cut two sides inside and $none none, not one cutting one or three; ${commas(whole)} cut all three side-lines at pegs, $wholeTwo of them two sides inside; $middle cut AB at its middle, all with two inside, $middleWhole of them at pegs throughout; and $twice cut BC twice as far from B as from C, at (4, 8), $throughFourEight lines through that peg less the four along the sides\' directions, to A and BC itself\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(lines.length)} lines land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${commas(lines.length)}, and the way in and out said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
