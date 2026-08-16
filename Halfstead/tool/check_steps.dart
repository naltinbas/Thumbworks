import 'dart:io';

import 'package:halfstead/step/frac.dart';
import 'package:halfstead/step/levels.dart';
import 'package:halfstead/step/play.dart';
import 'package:halfstead/step/rules.dart';

/// Adds up every run of steps on the dials as exact fractions, sets the
/// sum against the form, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_steps.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  check(Rules.shares.length == 5 && Rules.settings == 200, 'shares and settings');
  final within = <String, List<int>>{};
  for (final s in Rules.shares) {
    var last = Frac.one;
    for (var n = 1; n <= Rules.most; n++) {
      final bySum = Rules.coveredBySum(s, n), byForm = Rules.coveredByForm(s, n);
      check(bySum == byForm, '${Rules.tellShare(s)} x $n: sum $bySum, form $byForm');
      final left = Rules.left(s, n);
      check(left.compareTo(Frac.zero) > 0 && left.compareTo(last) < 0, 'left after $n of ${Rules.tellShare(s)}: $left, before $last');
      check(bySum + left == Frac.one, 'covered and left do not make the whole at $n of ${Rules.tellShare(s)}');
      // Each step is the share of what the last left, and shorter than the
      // last by the rest of the share.
      final steps = Rules.steps(s, n);
      check(steps.length == n && steps.first == s, 'the steps of ${Rules.tellShare(s)} x $n');
      for (var k = 1; k < n; k++) {
        check(steps[k] == steps[k - 1] * (Frac.one - s), 'step $k of ${Rules.tellShare(s)} is not the last times the rest');
      }
      last = left;
    }
    within[Rules.tellShare(s)] = [Rules.fewestWithin(s, Frac.of(1, 100)), Rules.fewestWithin(s, Frac.of(1, 1000)), Rules.fewestWithin(s, Frac.of(1, 1000000))];
  }
  check(within['half']!.join(',') == '7,10,20' && within['a third']!.join(',') == '12,18,35' && within['two thirds']!.join(',') == '5,7,13' && within['three quarters']!.join(',') == '4,5,10' && within['nine tenths']!.join(',') == '2,3,6', 'fewest steps within a hundredth, a thousandth, a millionth: $within');
  check(Rules.tell(Rules.left(Frac.of(1, 2), 7)) == '1/128' && Rules.tell(Rules.coveredByForm(Frac.of(1, 2), 7)) == '127/128' && Rules.tell(Rules.left(Frac.of(1, 2), 6)) == '1/64', 'seven halvings');
  check(Rules.tell(Rules.left(Frac.of(1, 2), 20)) == '1/1,048,576' && Rules.tell(Rules.left(Frac.of(1, 2), 40)) == '1/1,099,511,627,776', 'twenty and forty halvings');
  check(Rules.left(Frac.of(9, 10), 40) == Frac(BigInt.one, BigInt.from(10).pow(40)), 'forty steps of nine tenths');
  check(Rules.tell(Rules.coveredByForm(Frac.of(9, 10), 3)) == '999/1,000', 'three steps of nine tenths');
  check(Rules.steps(Frac.of(1, 2), 4).map(Rules.tell).join(' ') == '1/2 1/4 1/8 1/16', 'the halvings');
  final quarter = <String>[], sixtyFourth = <String>[];
  for (final s in Rules.shares) {
    for (var n = 1; n <= Rules.most; n++) {
      if (Rules.left(s, n) == Frac.of(1, 4)) quarter.add('${Rules.tellShare(s)} x $n');
      if (Rules.left(s, n) == Frac.of(1, 64)) sixtyFourth.add('${Rules.tellShare(s)} x $n');
    }
  }
  check(quarter.join('; ') == 'half x 2; three quarters x 1', 'a quarter left: $quarter');
  check(sixtyFourth.join('; ') == 'half x 6; three quarters x 3', 'a sixty-fourth left: $sixtyFourth');

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (final s in Rules.shares) {
      for (var k = 1; k <= Rules.most; k++) {
        if (level.meets(s, k)) n++;
      }
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
      while (!play.isDone && steps < 60) {
        final (which, way) = play.next!;
        play = play.set(which, way);
        steps++;
      }
      check(play.isDone, '${level.name}: the pointer never lands');
    }
  }
  check(Levels.at(0).aim == (Frac.of(1, 2), 7) && Levels.at(1).aim == (Frac.of(1, 2), 2) && Levels.at(2).aim == (Frac.of(9, 10), 3) && Levels.at(3).aim == (Frac.of(1, 2), 6), 'the aims');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every run of steps on the dials added up as exact fractions, five shares of what is left, half, a third, two thirds, three quarters and nine tenths, and one to forty steps of each, ${Rules.settings} settings, the sum agreeing with 1 less the rest to the n on all ${Rules.settings}, every step the share of what the last left, and what is left always something and always less than before; seven halvings come within a hundredth, 127/128 covered, ten within a thousandth and twenty within a millionth, 1/1,048,576 left, forty leaving 1/1,099,511,627,776; a third takes 12, 18 and 35 steps to the same marks, two thirds 5, 7 and 13, three quarters 4, 5 and 10, and nine tenths 2, 3 and 6, forty of them leaving one part in 10 to the fortieth; a quarter is left by two halvings or one step of three quarters and a sixty-fourth by six halvings or three steps of three quarters, and the wall is reached by none\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${Rules.settings} settings land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${Rules.settings}, and the rest of something said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
