import 'dart:io';

import 'package:ringfold/period/levels.dart';
import 'package:ringfold/period/play.dart';
import 'package:ringfold/period/rules.dart';

/// Walks the Fibonacci numbers round every clock on the dial and to two
/// hundred hours besides, finds each period again by the matrix, checks
/// Cassini's identity on every clock, and refuses the bake on any
/// disagreement.
///
/// Run with: dart run tool/check_periods.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  check(Rules.settings == 39, 'settings ${Rules.settings}');
  final periods = <int, int>{};
  var oddClocks = <int>[], ownLength = <int>[];
  for (var m = 2; m <= 200; m++) {
    final byWalk = Rules.periodByWalk(m), byMatrix = Rules.periodByMatrix(m);
    check(byWalk == byMatrix, 'clock $m: walk $byWalk, matrix $byMatrix');
    check(Rules.bound(m) % byWalk == 0, 'clock $m: period $byWalk does not divide the bound ${Rules.bound(m)}');
    check(Rules.cassiniHolds(m), 'Cassini fails on $m');
    final cycle = Rules.cycle(m);
    check(cycle.length == byWalk && cycle[0] == 0 && cycle[1] == 1 % m, 'the cycle of $m');
    for (var i = 2; i < cycle.length; i++) {
      check(cycle[i] == (cycle[i - 1] + cycle[i - 2]) % m, 'the cycle of $m breaks at $i');
    }
    check((cycle[cycle.length - 2] + cycle[cycle.length - 1]) % m == 0 && (cycle[cycle.length - 1] + 0) % m == 1 % m, 'the cycle of $m does not come round to 0, 1');
    if (byWalk.isOdd) oddClocks.add(m);
    if (byWalk == m) ownLength.add(m);
    if (m <= Rules.most) periods[m] = byWalk;
  }
  check(oddClocks.join(',') == '2', 'clocks with an odd period to two hundred: $oddClocks');
  check(ownLength.join(',') == '24,120', 'clocks whose period is their own length to two hundred: $ownLength');
  check([for (var m = 2; m <= 10; m++) periods[m]].join(',') == '3,8,6,20,24,16,12,24,60', 'the first periods: ${[for (var m = 2; m <= 10; m++) periods[m]]}');
  check(Rules.cycle(3).join(',') == '0,1,1,2,0,2,2,1' && Rules.cycle(2).join(',') == '0,1,1' && Rules.cycle(4).join(',') == '0,1,1,2,3,1', 'the small cycles');
  check(Rules.cycle(5).join(',') == '0,1,1,2,3,0,3,3,1,4,0,4,4,3,2,0,2,2,4,1', 'the five-hour cycle');
  final sixty = [for (var m = 2; m <= Rules.most; m++) if (periods[m] == 60) m];
  check(sixty.join(',') == '10,20,40', 'clocks with sixty: $sixty');
  check(periods[25] == 100 && Rules.periodByWalk(50) == 300 && periods[24] == 24 && periods[8] == 12, 'twenty-five, fifty, twenty-four, eight');
  check(periods[11] == 10 && periods[29] == 14 && periods[7] == 16 && periods[13] == 28, 'the prime clocks');
  final eight = [for (var m = 2; m <= Rules.most; m++) if (periods[m] == 8) m], twenty = [for (var m = 2; m <= Rules.most; m++) if (periods[m] == 20) m];
  check(eight.join(',') == '3' && twenty.join(',') == '5', 'eight $eight, twenty $twenty');
  var shortestPastTwo = 1000, shortestAt = 0;
  for (var m = 3; m <= Rules.most; m++) {
    if (periods[m]! < shortestPastTwo) {
      shortestPastTwo = periods[m]!;
      shortestAt = m;
    }
  }
  check(shortestPastTwo == 6 && shortestAt == 4, 'shortest past two: $shortestPastTwo at $shortestAt');
  final longest = periods.entries.reduce((a, b) => a.value >= b.value ? a : b);
  check(longest.key == 30 && longest.value == 120, 'longest on the dial: ${longest.key} ${longest.value}');

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (var m = Rules.least; m <= Rules.most; m++) {
      if (level.meets(m)) n++;
    }
    check(n == level.ways, '${level.name}: ${level.ways} said, $n swept');
    final aim = level.aim;
    check((aim == null) == !level.winnable, '${level.name}: aim $aim');
    if (aim != null) check(level.meets(aim), '${level.name}: the aim misses');
    final open = Play.of(level);
    check(!open.isOver, '${level.name}: opens over');
    if (aim != null) {
      var play = open;
      var steps = 0;
      while (!play.isDone && steps < 20) {
        play = play.wind(play.next!);
        steps++;
      }
      check(play.isDone, '${level.name}: the pointer never lands');
    }
  }
  check(Levels.at(0).aim == 3 && Levels.at(1).aim == 5 && Levels.at(2).aim == 10 && Levels.at(3).aim == 24, 'the aims');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('the Fibonacci numbers walked round every clock from two to two hundred hours until 0, 1 came round, and each period found again as the least divisor of the bound from the clock\'s prime factors that brings the Fibonacci matrix back to the identity, the two agreeing on all 199 clocks and Cassini\'s identity holding on every one; the periods run 3, 8, 6, 20, 24, 16, 12, 24, 60 for two to ten hours, 120 for thirty, the longest on the dial, and 300 for fifty; the two-hour clock alone has an odd period, and every clock from three to two hundred an even one, six on the four-hour clock the shortest; twenty-four and a hundred and twenty are the clocks whose period is their own length; on the dial, two to forty hours, ${Rules.settings} clocks, three has eight, five twenty, ten, twenty and forty sixty, and twenty-four twenty-four\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${Rules.settings} clocks land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${Rules.settings}, and Cassini said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
