import 'dart:io';

import 'package:kithwell/kith/frac.dart';
import 'package:kithwell/kith/level.dart';
import 'package:kithwell/kith/levels.dart';
import 'package:kithwell/kith/play.dart';
import 'package:kithwell/kith/rules.dart';

/// Names every friendship of every plan two ways, counts what the
/// paradox promises, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_fairs.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  check(Rules.people == 6 && Rules.pairs.length == 15 && Rules.plans == 32768, 'the people and pairs');
  var under = 0, even = 0, one = 0, half = 0, quarter = 0, widest = 0, pbpUnder = 0;
  final gaps = <Frac>{};
  Frac? most;
  for (var mask = 1; mask < Rules.plans; mask++) {
    final byNaming = Rules.friendsAverage(mask), bySquares = Rules.friendsAverageBySquares(mask);
    check(byNaming != null && bySquares != null && byNaming == bySquares, 'the two averages differ on ${Rules.tell(mask)}');
    final average = Rules.average(mask);
    final gap = byNaming! - average;
    check(gap == Rules.spread(mask) / average, 'the gap is not the spread over the average on ${Rules.tell(mask)}');
    check(Rules.gap(mask) == gap, 'the gap on ${Rules.tell(mask)}');
    final d = Rules.degrees(mask);
    check((gap == Frac.zero) == d.every((x) => x == d.first), 'the gap and the evenness on ${Rules.tell(mask)}');
    if (gap.compareTo(Frac.zero) < 0) under++;
    if (gap == Frac.zero) even++;
    if (gap == Frac.one) one++;
    if (gap == Frac.of(1, 2)) half++;
    if (gap == Frac.of(1, 4)) quarter++;
    if (gap == Level.widest) widest++;
    gaps.add(gap);
    if (most == null || gap.compareTo(most) > 0) most = gap;
    final pbp = Rules.personByPerson(mask);
    if (pbp != null && pbp.compareTo(average) < 0) pbpUnder++;
  }
  check(under == 0 && pbpUnder == 0, 'under $under, person by person under $pbpUnder');
  check(even == 171 && one == 155 && half == 1080 && quarter == 80 && widest == 6, 'even $even, one $one, half $half, quarter $quarter, widest $widest');
  check(most == Level.widest && gaps.length == 41, 'the widest gap $most, ${gaps.length} gaps');
  final star = Rules.planOf('Ann-Bess, Ann-Cal, Ann-Dot, Ann-Ed, Ann-Fay');
  check(Rules.degrees(star).join(',') == '5,1,1,1,1,1' && tellFrac(Rules.average(star)) == '1 2/3' && tellFrac(Rules.friendsAverage(star)!) == '3' && tellFrac(Rules.gap(star)!) == '1 1/3', 'the star');
  final one1 = Rules.planOf('Ann-Bess');
  check(tellFrac(Rules.average(one1)) == '1/3' && tellFrac(Rules.friendsAverage(one1)!) == '1' && tellFrac(Rules.gap(one1)!) == '2/3', 'one friendship');
  check(Rules.friendsAverage(0) == null && Rules.gap(0) == null, 'the empty fair');
  var commonest = 0;
  for (var mask = 1; mask < Rules.plans; mask++) {
    if (Rules.gap(mask) == Frac.of(1, 3)) commonest++;
  }
  check(commonest == 5742, 'the gap of a third on $commonest');

  // The asks.
  for (final level in Levels.all) {
    var ways = 0;
    for (var mask = 1; mask < Rules.plans; mask++) {
      if (level.meets(mask)) ways++;
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
      while (!play.isDone && steps < 40) {
        final (a, b, _) = play.next!;
        play = play.tap(a == b ? a : (play.held == a ? b : a));
        steps++;
      }
      check(play.isDone, '${level.name}: the pointer never lands');
    }
  }
  check(Rules.tell(Levels.at(0).aim!) == 'Ann-Fay, Bess-Ed, Cal-Dot' && Rules.tell(Levels.at(2).aim!) == 'Ann-Bess, Ann-Cal, Ann-Dot, Ann-Ed, Ann-Fay', 'the aims');
  var dead = Play.of(Levels.at(4));
  for (final p in [(0, 1), (2, 3), (4, 5), (0, 1), (2, 3), (0, 2), (1, 3), (0, 2), (1, 3), (0, 3), (1, 2)]) {
    dead = dead.tap(p.$1).tap(p.$2);
  }
  check(dead.gaveUp, 'the popular few does not admit it after three even plans: seen ${dead.seen.length}, gap ${dead.gap}, moves ${dead.moves}');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every plan of friendships among the six taken, ${commas(Rules.plans)}, and on every one with a friendship in it, ${commas(Rules.plans - 1)}, the friends\' average found two ways, by naming every friendship from both ends and taking down the named friend\'s count, and by the sum of the squares of the counts over the sum of the counts, the two agreeing on all: the friends named are never behind, level on the $even plans where everyone has the same number of friends and ahead on the rest, the gap being the spread of the counts over their average; person by person too, each one\'s own friends averaged and those averaged, they are never behind, on all ${commas(Rules.plans - 1)}; the gap is widest, 1 1/3, on the six stars, where people average 1 2/3 friends and the friends named 3, and ${gaps.length} different gaps come in all, a third the commonest on ${commas(commonest)} plans, one on $one, a half on ${commas(half)} and a quarter on $quarter; one friendship alone gives an average of a third and a friends\' average of one\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(Rules.plans - 1)} plans land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${commas(Rules.plans - 1)}, and the spread said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
