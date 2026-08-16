import 'dart:io';

import 'package:shortcombe/road/levels.dart';
import 'package:shortcombe/road/play.dart';
import 'package:shortcombe/road/rules.dart';

/// Settles every crowd on the dial with the shortcut open and shut, by
/// cases and by the least potential, checks that no driver gains by
/// switching, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_roads.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  check(Rules.settings == 60, 'settings ${Rules.settings}');
  var helps = 0, hurts = 0, noOdds = 0, worst = 0, worstAt = 0;
  final journeysShut = <int>[];
  for (var crowd = Rules.least; crowd <= Rules.most; crowd += Rules.step) {
    for (final open in [false, true]) {
      final byCases = Rules.settle(crowd, open), byPotential = Rules.settleByPotential(crowd, open);
      check(byCases == byPotential, 'crowd $crowd, ${open ? 'open' : 'shut'}: cases $byCases, potential $byPotential');
      final (top, bottom, across) = byCases;
      check(top + bottom + across == crowd && top >= 0 && bottom >= 0 && across >= 0 && (open || across == 0), 'split of $crowd ${open ? 'open' : 'shut'}: $byCases');
      // The potential's least is its own: no other split ties.
      final least = Rules.potential(top, bottom, across);
      var ties = 0;
      for (var a = 0; a <= (open ? crowd : 0); a++) {
        for (var t = 0; t + a <= crowd; t++) {
          if (Rules.potential(t, crowd - t - a, a) == least) ties++;
        }
      }
      check(ties == 1, 'potential ties at $crowd ${open ? 'open' : 'shut'}: $ties');
      // No driver gains by switching: every used way takes the settled
      // journey, and no way takes less.
      final (t, b, a) = Rules.minutes(crowd, open);
      final journey = Rules.journey(crowd, open);
      final ways = [(top, t), (bottom, b), if (open) (across, a!)];
      for (final (flow, mins) in ways) {
        check(mins >= journey, 'a way faster than the journey at $crowd ${open ? 'open' : 'shut'}: $mins < $journey');
        if (flow > 0) check(mins == journey, 'a used way slower than the journey at $crowd ${open ? 'open' : 'shut'}: $mins');
      }
      if (!open) journeysShut.add(journey);
    }
    final verdict = Rules.verdictOf(crowd);
    if (verdict == 'helps') helps++;
    if (verdict == 'hurts') hurts++;
    if (verdict == 'no odds') noOdds++;
    final gap = Rules.journey(crowd, true) - Rules.journey(crowd, false);
    if (gap > worst) {
      worst = gap;
      worstAt = crowd;
    }
    check(verdict == (crowd < 30 ? 'helps' : crowd == 30 ? 'no odds' : 'hurts'), 'verdict at $crowd: $verdict');
    check(Rules.journey(crowd, false) == Rules.fixed + crowd ~/ 2, 'shut journey at $crowd');
    check(Rules.journey(crowd, true) == (crowd <= Rules.fixed ? 2 * crowd : 2 * Rules.fixed), 'open journey at $crowd');
  }
  check(helps == 14 && noOdds == 1 && hurts == 15, 'helps $helps, no odds $noOdds, hurts $hurts');
  check(worst == 22 && worstAt == 46, 'the worst hurt: $worst at $worstAt');
  check(journeysShut.first == 46 && journeysShut.last == 75, 'shut journeys run ${journeysShut.first} to ${journeysShut.last}');
  check(Rules.journey(40, false) == 65 && Rules.journey(40, true) == 80 && Rules.settle(40, false) == (20, 20, 0) && Rules.settle(40, true) == (0, 0, 40), 'forty hundred');
  check(Rules.minutes(40, true) == (85, 85, 80), 'forty hundred\'s ways open');
  check(Rules.journey(2, true) == 4 && Rules.journey(2, false) == 46 && Rules.journey(20, true) == 40 && Rules.journey(20, false) == 55 && Rules.journey(28, true) == 56 && Rules.journey(28, false) == 59, 'the helped crowds');
  check(Rules.journey(30, true) == 60 && Rules.journey(30, false) == 60 && Rules.settle(30, false) == (15, 15, 0) && Rules.settle(30, true) == (0, 0, 30), 'thirty hundred');
  check(Rules.journey(32, true) - Rules.journey(32, false) == 3 && Rules.journey(60, true) - Rules.journey(60, false) == 15 && Rules.journey(46, true) - Rules.journey(46, false) == 22, 'the hurt crowds');
  check(Rules.settle(50, true) == (5, 5, 40) && Rules.journey(50, true) == 90 && Rules.journey(50, false) == 70, 'fifty hundred');
  check(Rules.tell(40) == 'forty hundred' && Rules.tell(28) == 'twenty-eight hundred' && Rules.tell(2) == 'two hundred', 'the telling');

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (var crowd = Rules.least; crowd <= Rules.most; crowd += Rules.step) {
      for (final open in [false, true]) {
        if (level.meets(crowd, open)) n++;
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
      while (!play.isDone && steps < 40) {
        final (which, way) = play.next!;
        play = play.set(which, way);
        steps++;
      }
      check(play.isDone, '${level.name}: the pointer never lands');
    }
  }
  check(Levels.at(0).aim == (40, false) && Levels.at(1).aim == (40, true) && Levels.at(2).aim == (2, true) && Levels.at(3).aim == (30, false), 'the aims');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every crowd from two hundred to sixty hundred, two hundred a step, settled with the shortcut shut and with it open, ${Rules.settings} settings, by cases and again by the least potential over every whole split of the crowd, the two agreeing on all ${Rules.settings} with the least split its own every time, and on every settling every way in use taking the same minutes and no way taking fewer; with the shortcut shut the crowd splits evenly and takes 45 plus half the crowd, 46 minutes for two hundred to 75 for sixty; with it open every driver under forty-five hundred goes across and takes twice the crowd, and from forty-five hundred on the settled journey is 90; the shortcut helps 14 crowds of the 30, under thirty hundred, makes no odds at thirty, 60 minutes either way, and hurts 15, by 3 minutes at thirty-two hundred, 15 at forty and 22 at forty-six, the most; forty hundred take 65 with it shut and 80 with it open\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${Rules.settings} settings land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${Rules.settings}, and the way across said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
