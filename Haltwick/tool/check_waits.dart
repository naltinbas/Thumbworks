import 'dart:io';

import 'package:haltwick/wait/frac.dart';
import 'package:haltwick/wait/level.dart';
import 'package:haltwick/wait/levels.dart';
import 'package:haltwick/wait/play.dart';
import 'package:haltwick/wait/rules.dart';

/// Waits out every timetable two ways, counts what the paradox promises,
/// and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_waits.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  final all = Rules.timetables;
  check(all.length == 1711 && all.first.join(',') == '1,1,58' && all.last.join(',') == '58,1,1', 'the timetables: ${all.length}');
  check(Rules.fairWait == Frac.of(19, 2) && Rules.tell(Rules.fairWait) == '9 1/2', 'the fair wait ${Rules.fairWait}');
  var under = 0, atFair = 0, quarter = 0, twenty = 0, halves = 0, wholes = 0, minuteApart = 0, atWorst = 0;
  Frac? least, most;
  for (final g in all) {
    check(Rules.valid(g), 'a timetable off the hour: $g');
    final byGaps = Rules.waitByGaps(g), byMinutes = Rules.waitByMinutes(g);
    check(byGaps == byMinutes, 'the two waits differ on $g: $byGaps and $byMinutes');
    // The waits within a gap run g - 1 down to 0.
    final at = Rules.busesAt(g);
    check(at.join(',') == '0,${g[0]},${g[0] + g[1]}', 'the buses of $g come at $at');
    check(Rules.waitAt(g, 0) == 0 && Rules.waitAt(g, 1) == (g[0] == 1 ? 0 : g[0] - 1), 'the waits at the start of $g');
    if (byGaps.compareTo(Rules.fairWait) < 0) under++;
    if (byGaps == Rules.fairWait) atFair++;
    if (byGaps.compareTo(Frac.of(15)) >= 0) quarter++;
    if (byGaps.compareTo(Frac.of(20)) >= 0) twenty++;
    if (byGaps.d == BigInt.two) halves++;
    if (byGaps.isWhole) wholes++;
    if (g.contains(1)) minuteApart++;
    if (byGaps == Level.worst) atWorst++;
    if (least == null || byGaps.compareTo(least) < 0) least = byGaps;
    if (most == null || byGaps.compareTo(most) > 0) most = byGaps;
  }
  check(under == 0 && atFair == 1 && least == Rules.fairWait, 'under the fair $under, at it $atFair, least $least');
  check(most == Level.worst && atWorst == 3 && Rules.tell(Level.worst) == '27 11/20', 'the worst $most, $atWorst timetables');
  check(quarter == 555 && twenty == 165 && halves == 4 && wholes == 0 && minuteApart == 171, 'quarter $quarter, twenty $twenty, halves $halves, wholes $wholes, a minute apart $minuteApart');
  check(Rules.waitByGaps([20, 20, 20]) == Frac.of(19, 2) && Rules.waitByGaps([10, 10, 40]) == Frac.of(29, 2) && Rules.waitByGaps([1, 1, 58]) == Frac.of(551, 20) && Rules.tell(Rules.waitByGaps([10, 20, 30])) == '11 1/6', 'the named timetables');
  // The squares: three gaps adding to sixty square to 1,200 at least, and the waiting is 570 minutes at least.
  var leastSquares = 1 << 30, leastWaiting = 1 << 30;
  for (final g in all) {
    final squares = g.fold(0, (a, x) => a + x * x), waiting = g.fold(0, (a, x) => a + x * (x - 1)) ~/ 2;
    if (squares < leastSquares) leastSquares = squares;
    if (waiting < leastWaiting) leastWaiting = waiting;
  }
  check(leastSquares == 1200 && leastWaiting == 570, 'least squares $leastSquares, least waiting $leastWaiting');

  // The asks.
  for (final level in Levels.all) {
    var ways = 0;
    for (final g in all) {
      if (level.meets(g)) ways++;
    }
    check(ways == level.ways, '${level.name}: ${level.ways} said, $ways swept');
    final aim = level.aim;
    check((aim == null) == !level.winnable, '${level.name}: aim $aim');
    if (aim != null) check(level.meets(aim), '${level.name}: the aim misses');
    final open = Play.of(level);
    check(!open.isOver, '${level.name}: opens over');
    if (aim != null) {
      var play = open;
      var steps = 0;
      while (!play.isDone && steps < 60) {
        final (which, by) = play.next!;
        play = play.step(which, by);
        steps++;
      }
      check(play.isDone, '${level.name}: the pointer never lands');
    }
  }
  check(Levels.at(0).aim!.join(',') == '20,20,20' && Levels.at(1).aim!.join(',') == '10,10,40' && Levels.at(3).aim!.join(',') == '1,1,58', 'the aims');
  var dead = Play.of(Levels.at(4));
  for (var k = 0; k < 10; k++) {
    dead = dead.step('g1', 1);
  }
  check(dead.gaps.join(',') == '20,20,20' && dead.gaveUp, 'the short wait does not admit it at the fair timetable');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every timetable of three buses an hour taken, ${commas(all.length)}, the gaps a minute or more and adding to sixty, and the average wait found on each two ways, gap by gap from the sum of each gap\'s waits and minute by minute from the wait at every minute of the hour, the two agreeing on all ${commas(all.length)}: the least is 9 1/2 minutes, from the gaps 20, 20 and 20 alone, and none is under it, the three gaps squaring to 1,200 at least and the waiting in an hour coming to 570 minutes at least; the most is 27 11/20, from 1, 1 and 58 in its three orders; $quarter timetables wait a quarter hour or more, $twenty twenty minutes or more, and $minuteApart have two buses a minute apart; four waits end in a half, 9 1/2 and the 14 1/2 of 10, 10 and 40 in its three orders, and no wait is a whole number of minutes; 10, 20 and 30 wait 11 1/6\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${commas(all.length)} timetables land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${commas(all.length)}, and the squares said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
