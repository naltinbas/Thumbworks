import 'dart:io';

import 'package:cofferwick/coffer/frac.dart';
import 'package:cofferwick/coffer/levels.dart';
import 'package:cofferwick/coffer/play.dart';
import 'package:cofferwick/coffer/rules.dart';

/// Lays the six coins every way, works every chance by the draws and by
/// Bayes, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_coffers.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  check(Rules.settings == 64, 'settings ${Rules.settings}');
  final byChance = <String, int>{};
  final withThree = <String, int>{};
  var three = 0;
  for (var n = 0; n < Rules.settings; n++) {
    final coins = Rules.laying(n);
    final byDraws = Rules.chanceByDraws(coins), byBayes = Rules.chanceByBayes(coins);
    check(byDraws == byBayes, 'laying $n: draws $byDraws, Bayes $byBayes');
    final (gg, gs, ss) = Rules.sorts(coins);
    check(gg + gs + ss == 3 && 2 * gg + gs == Rules.golds(coins), 'sorts of $n');
    // The chance is twice the gold pairs over the gold coins, and lies
    // between 0 and 1.
    if (Rules.golds(coins) > 0) {
      check(byDraws == Frac.of(2 * gg, 2 * gg + gs), 'chance of $n against 2GG over gold');
      check(byDraws!.compareTo(Frac.zero) >= 0 && byDraws.compareTo(Frac.one) <= 0, 'chance of $n out of range');
    } else {
      check(byDraws == null && n == 0, 'no gold at $n');
    }
    final key = Rules.tellChance(byDraws);
    byChance[key] = (byChance[key] ?? 0) + 1;
    if (Rules.golds(coins) == 3) {
      three++;
      withThree[key] = (withThree[key] ?? 0) + 1;
    }
  }
  check(byChance['0, never'] == 26 && byChance['1/2'] == 12 && byChance['2/3'] == 12 && byChance['4/5'] == 6 && byChance['1, certain'] == 7 && byChance['none, no gold coin to draw'] == 1 && byChance.length == 6, 'chances by laying: $byChance');
  check(three == 20 && withThree['2/3'] == 12 && withThree['0, never'] == 8 && withThree.length == 2, 'three gold coins: $withThree');
  check(Rules.chanceByDraws(Rules.laying(7)) == Frac.of(2, 3) && Rules.sorts(Rules.laying(7)) == (1, 1, 1), 'Bertrand\'s laying');

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (var k = 0; k < Rules.settings; k++) {
      if (level.meets(Rules.laying(k))) n++;
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
      while (!play.isDone && steps < 8) {
        play = play.tap(play.next!);
        steps++;
      }
      check(play.isDone, '${level.name}: the pointer never lands');
    }
  }
  check(Levels.at(0).settings == 64 && Levels.at(4).settings == 20, 'the settings of the asks');
  check(Levels.at(0).aim!.join(',') == 'true,true,true,false,false,false', 'the two thirds\' aim');
  check(Levels.at(1).aim!.join(',') == 'true,true,true,false,true,false', 'the half\'s aim');
  check(Levels.at(2).aim!.join(',') == 'true,true,true,true,true,false', 'the four fifths\' aim');
  check(Levels.at(3).aim!.join(',') == 'true,true,false,false,false,false', 'the certain\'s aim');
  // The certain: 3 + 3 + 1 layings by the sorts.
  var one = 0, two = 0, all = 0;
  for (var k = 0; k < Rules.settings; k++) {
    final coins = Rules.laying(k);
    if (!Levels.at(3).meets(coins)) continue;
    final (gg, _, _) = Rules.sorts(coins);
    if (gg == 1) one++;
    if (gg == 2) two++;
    if (gg == 3) all++;
  }
  check(one == 3 && two == 3 && all == 1, 'the certain by pairs: $one $two $all');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every laying of the six coins in the three coffers swept, ${Rules.settings} of them, and on each the chance that a gold coin drawn at random has a gold mate was worked by the six draws, a coffer then a coin, and again by Bayes with each coffer a third, the two agreeing on all ${Rules.settings}; the chances that come are 0 on 26 layings, a half on 12, two thirds on 12, four fifths on 6 and certainty on 7, with the all-silver laying giving no gold coin to draw; Bertrand\'s own laying, gold and gold, gold and silver, silver and silver, gives 2 in 3; and of the 20 layings of three gold coins and three silver, 12 give 2 in 3 and 8 give 0, and none a half\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${level.settings} layings land${level.ways == 1 ? 's' : ''} it'
        : 'none of its ${level.settings} layings, and the one gold pair said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
